{DEFAULT @resultsDatabaseSchema = 'webapi.dbo'}
{DEFAULT @vocabDatabaseSchema = 'omopcdm.dbo'}

/*********************************************************************/
/***** Create hierarchy lookup table for the treemap hierarchies *****/
/*********************************************************************/
IF OBJECT_ID('@resultsDatabaseSchema.concept_hierarchy', 'U') IS NOT NULL
  DROP TABLE @resultsDatabaseSchema.concept_hierarchy;


/***********************************************************/
/***** Populate the hierarchy lookup table per treemap *****/
/***********************************************************/
/********** CONDITION/CONDITION_ERA **********/


  SELECT
    snomed.concept_id,
    snomed.concept_name AS concept_name,
    'Condition' AS treemap,
    null as concept_hierarchy_type,
    pt_to_hlt.pt_concept_name as level1_concept_name,
    hlt_to_hlgt.hlt_concept_name as level2_concept_name,
    hlgt_to_soc.hlgt_concept_name as level3_concept_name,
    soc.concept_name    AS level4_concept_name
into #ch_condition
  FROM
    (
      SELECT
        concept_id,
        concept_name
      FROM @vocabDatabaseSchema.concept
      WHERE domain_id = 'Condition'
    ) snomed
    LEFT JOIN
    (SELECT
       c1.concept_id      AS snomed_concept_id,
       max(c2.concept_id) AS pt_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.domain_id = 'Condition'
            AND ca1.min_levels_of_separation = 1
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'MedDRA'
     GROUP BY c1.concept_id
    ) snomed_to_pt
      ON snomed.concept_id = snomed_to_pt.snomed_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS pt_concept_id,
       c1.concept_name    AS pt_concept_name,
       max(c2.concept_id) AS hlt_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'MedDRA'
            AND ca1.min_levels_of_separation = 1
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'MedDRA'
     GROUP BY c1.concept_id, c1.concept_name
    ) pt_to_hlt
      ON snomed_to_pt.pt_concept_id = pt_to_hlt.pt_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS hlt_concept_id,
       c1.concept_name    AS hlt_concept_name,
       max(c2.concept_id) AS hlgt_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'MedDRA'
            AND ca1.min_levels_of_separation = 1
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'MedDRA'
     GROUP BY c1.concept_id, c1.concept_name
    ) hlt_to_hlgt
      ON pt_to_hlt.hlt_concept_id = hlt_to_hlgt.hlt_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS hlgt_concept_id,
       c1.concept_name    AS hlgt_concept_name,
       max(c2.concept_id) AS soc_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'MedDRA'
            AND ca1.min_levels_of_separation = 1
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'MedDRA'
     GROUP BY c1.concept_id, c1.concept_name
    ) hlgt_to_soc
      ON hlt_to_hlgt.hlgt_concept_id = hlgt_to_soc.hlgt_concept_id

    LEFT JOIN @vocabDatabaseSchema.concept soc
      ON hlgt_to_soc.soc_concept_id = soc.concept_id;

/********** DRUG **********/

  SELECT
    rxnorm.concept_id,
    rxnorm.concept_name AS concept_name,
    'Drug' AS treemap,
    null as concept_hierarchy_type,    
    rxnorm.rxnorm_ingredient_concept_name as level1_concept_name,
    atc5_to_atc3.atc5_concept_name as level2_concept_name,
    atc3_to_atc1.atc3_concept_name as level3_concept_name,
    atc1.concept_name   AS level4_concept_name
into #ch_drug
  FROM
    (
      SELECT
        c1.concept_id,
        c1.concept_name,
        c2.concept_id   AS rxnorm_ingredient_concept_id,
        c2.concept_name AS RxNorm_ingredient_concept_name
      FROM @vocabDatabaseSchema.concept c1
        INNER JOIN @vocabDatabaseSchema.concept_ancestor ca1
          ON c1.concept_id = ca1.descendant_concept_id
             AND c1.domain_id = 'Drug'
        INNER JOIN @vocabDatabaseSchema.concept c2
          ON ca1.ancestor_concept_id = c2.concept_id
             AND c2.domain_id = 'Drug'
             AND c2.concept_class_id = 'Ingredient'
    ) rxnorm
    LEFT JOIN
    (SELECT
       c1.concept_id      AS rxnorm_ingredient_concept_id,
       max(c2.concept_id) AS atc5_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.domain_id = 'Drug'
            AND c1.concept_class_id = 'Ingredient'
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'ATC'
            AND c2.concept_class_id = 'ATC 4th'
     GROUP BY c1.concept_id
    ) rxnorm_to_atc5
      ON rxnorm.rxnorm_ingredient_concept_id = rxnorm_to_atc5.rxnorm_ingredient_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS atc5_concept_id,
       c1.concept_name    AS atc5_concept_name,
       max(c2.concept_id) AS atc3_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'ATC'
            AND c1.concept_class_id = 'ATC 4th'
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'ATC'
            AND c2.concept_class_id = 'ATC 2nd'
     GROUP BY c1.concept_id, c1.concept_name
    ) atc5_to_atc3
      ON rxnorm_to_atc5.atc5_concept_id = atc5_to_atc3.atc5_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS atc3_concept_id,
       c1.concept_name    AS atc3_concept_name,
       max(c2.concept_id) AS atc1_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'ATC'
            AND c1.concept_class_id = 'ATC 2nd'
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'ATC'
            AND c2.concept_class_id = 'ATC 1st'
     GROUP BY c1.concept_id, c1.concept_name
    ) atc3_to_atc1
      ON atc5_to_atc3.atc3_concept_id = atc3_to_atc1.atc3_concept_id

    LEFT JOIN @vocabDatabaseSchema.concept atc1
      ON atc3_to_atc1.atc1_concept_id = atc1.concept_id;

/********** DRUG_ERA **********/

  SELECT
    rxnorm.rxnorm_ingredient_concept_id as concept_id,
    rxnorm.rxnorm_ingredient_concept_name as concept_name,
    'Drug Era' AS treemap,
    null as concept_hierarchy_type,
    atc5_to_atc3.atc5_concept_name as level1_concept_name,
    atc3_to_atc1.atc3_concept_name as level2_concept_name,
    atc1.concept_name as level3_concept_name,
    null as level4_concept_name
into #ch_drug_era
  FROM
    (
      SELECT
        c2.concept_id   AS rxnorm_ingredient_concept_id,
        c2.concept_name AS RxNorm_ingredient_concept_name
      FROM
        @vocabDatabaseSchema.concept c2
      WHERE
        c2.domain_id = 'Drug'
        AND c2.concept_class_id = 'Ingredient'
    ) rxnorm
    LEFT JOIN
    (SELECT
       c1.concept_id      AS rxnorm_ingredient_concept_id,
       max(c2.concept_id) AS atc5_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.domain_id = 'Drug'
            AND c1.concept_class_id = 'Ingredient'
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'ATC'
            AND c2.concept_class_id = 'ATC 4th'
     GROUP BY c1.concept_id
    ) rxnorm_to_atc5
      ON rxnorm.rxnorm_ingredient_concept_id = rxnorm_to_atc5.rxnorm_ingredient_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS atc5_concept_id,
       c1.concept_name    AS atc5_concept_name,
       max(c2.concept_id) AS atc3_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'ATC'
            AND c1.concept_class_id = 'ATC 4th'
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'ATC'
            AND c2.concept_class_id = 'ATC 2nd'
     GROUP BY c1.concept_id, c1.concept_name
    ) atc5_to_atc3
      ON rxnorm_to_atc5.atc5_concept_id = atc5_to_atc3.atc5_concept_id

    LEFT JOIN
    (SELECT
       c1.concept_id      AS atc3_concept_id,
       c1.concept_name    AS atc3_concept_name,
       max(c2.concept_id) AS atc1_concept_id
     FROM
       @vocabDatabaseSchema.concept c1
       INNER JOIN
       @vocabDatabaseSchema.concept_ancestor ca1
         ON c1.concept_id = ca1.descendant_concept_id
            AND c1.vocabulary_id = 'ATC'
            AND c1.concept_class_id = 'ATC 2nd'
       INNER JOIN
       @vocabDatabaseSchema.concept c2
         ON ca1.ancestor_concept_id = c2.concept_id
            AND c2.vocabulary_id = 'ATC'
            AND c2.concept_class_id = 'ATC 1st'
     GROUP BY c1.concept_id, c1.concept_name
    ) atc3_to_atc1
      ON atc5_to_atc3.atc3_concept_id = atc3_to_atc1.atc3_concept_id

    LEFT JOIN @vocabDatabaseSchema.concept atc1
      ON atc3_to_atc1.atc1_concept_id = atc1.concept_id;

/********** MEASUREMENT **********/

  SELECT
    m.concept_id,
    m.concept_name,
    'Measurement' AS treemap,
    null as concept_hierarchy_type,
    max(c1.concept_name) AS level1_concept_name,
    max(c2.concept_name) AS level2_concept_name,
    max(c3.concept_name) AS level3_concept_name,
    null as level4_concept_name
into #ch_measurement
  FROM
    (
      SELECT DISTINCT
        concept_id,
        concept_name
      FROM @vocabDatabaseSchema.concept c
      WHERE domain_id = 'Measurement'
    ) m
    LEFT JOIN @vocabDatabaseSchema.concept_ancestor ca1
      ON M.concept_id = ca1.DESCENDANT_CONCEPT_ID AND ca1.min_levels_of_separation = 1
    LEFT JOIN @vocabDatabaseSchema.concept c1 ON ca1.ANCESTOR_CONCEPT_ID = c1.concept_id
    LEFT JOIN @vocabDatabaseSchema.concept_ancestor ca2
      ON c1.concept_id = ca2.DESCENDANT_CONCEPT_ID AND ca2.min_levels_of_separation = 1
    LEFT JOIN @vocabDatabaseSchema.concept c2 ON ca2.ANCESTOR_CONCEPT_ID = c2.concept_id
    LEFT JOIN @vocabDatabaseSchema.concept_ancestor ca3
      ON c2.concept_id = ca3.DESCENDANT_CONCEPT_ID AND ca3.min_levels_of_separation = 1
    LEFT JOIN @vocabDatabaseSchema.concept c3 ON ca3.ANCESTOR_CONCEPT_ID = c3.concept_id
  GROUP BY M.concept_id, M.concept_name;

/********** OBSERVATION **********/

  SELECT
    obs.concept_id,
    obs.concept_name,
    'Observation' AS treemap,
    null as concept_hierarchy_type,
    max(c1.concept_name) AS level1_concept_name,
    max(c2.concept_name) AS level2_concept_name,
    max(c3.concept_name) AS level3_concept_name,
    null as level4_concept_name
into #ch_observation
  FROM
    (
      SELECT
        concept_id,
        concept_name
      FROM @vocabDatabaseSchema.concept
      WHERE domain_id = 'Observation'
    ) obs
    LEFT JOIN @vocabDatabaseSchema.concept_ancestor ca1
      ON obs.concept_id = ca1.DESCENDANT_CONCEPT_ID AND ca1.min_levels_of_separation = 1
    LEFT JOIN @vocabDatabaseSchema.concept c1 ON ca1.ANCESTOR_CONCEPT_ID = c1.concept_id
    LEFT JOIN @vocabDatabaseSchema.concept_ancestor ca2
      ON c1.concept_id = ca2.DESCENDANT_CONCEPT_ID AND ca2.min_levels_of_separation = 1
    LEFT JOIN @vocabDatabaseSchema.concept c2 ON ca2.ANCESTOR_CONCEPT_ID = c2.concept_id
    LEFT JOIN @vocabDatabaseSchema.concept_ancestor ca3
      ON c2.concept_id = ca3.DESCENDANT_CONCEPT_ID AND ca3.min_levels_of_separation = 1
    LEFT JOIN @vocabDatabaseSchema.concept c3 ON ca3.ANCESTOR_CONCEPT_ID = c3.concept_id
  GROUP BY obs.concept_id, obs.concept_name;

/********** PROCEDURE **********/

  SELECT
    procs.concept_id,
    procs.proc_concept_name as concept_name,
    'Procedure' AS treemap,
    null as concept_hierarchy_type,
    max(proc_hierarchy.os3_concept_name) AS level1_concept_name,
    max(proc_hierarchy.os2_concept_name) AS level2_concept_name,
    max(proc_hierarchy.os1_concept_name) AS level3_concept_name,
    null as level4_concept_name
into #ch_procedure
  FROM
    (
      SELECT
        c1.concept_id,
        v1.vocabulary_name + ' ' + c1.concept_code + ': ' + c1.concept_name AS proc_concept_name
      FROM @vocabDatabaseSchema.concept c1
        INNER JOIN @vocabDatabaseSchema.vocabulary v1
          ON c1.vocabulary_id = v1.vocabulary_id
      WHERE c1.domain_id = 'Procedure'
    ) procs
    LEFT JOIN
    (SELECT
       ca0.DESCENDANT_CONCEPT_ID,
       max(ca0.ancestor_concept_id) AS ancestor_concept_id
     FROM @vocabDatabaseSchema.concept_ancestor ca0
       INNER JOIN
       (SELECT DISTINCT c2.concept_id AS os3_concept_id
        FROM @vocabDatabaseSchema.concept_ancestor ca1
          INNER JOIN
          @vocabDatabaseSchema.concept c1
            ON ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
          INNER JOIN
          @vocabDatabaseSchema.concept_ancestor ca2
            ON c1.concept_id = ca2.ANCESTOR_CONCEPT_ID
          INNER JOIN
          @vocabDatabaseSchema.concept c2
            ON ca2.DESCENDANT_CONCEPT_ID = c2.concept_id
        WHERE ca1.ancestor_concept_id = 4040390
              AND ca1.Min_LEVELS_OF_SEPARATION = 2
              AND ca2.MIN_LEVELS_OF_SEPARATION = 1
       ) t1
         ON ca0.ANCESTOR_CONCEPT_ID = t1.os3_concept_id
     GROUP BY ca0.descendant_concept_id
    ) ca1
      ON procs.concept_id = ca1.DESCENDANT_CONCEPT_ID
    LEFT JOIN
    (
      SELECT
        proc_by_os1.os1_concept_name,
        proc_by_os2.os2_concept_name,
        proc_by_os3.os3_concept_name,
        proc_by_os3.os3_concept_id
      FROM
        (SELECT
           DESCENDANT_CONCEPT_ID AS os1_concept_id,
           concept_name          AS os1_concept_name
         FROM @vocabDatabaseSchema.concept_ancestor ca1
           INNER JOIN
           @vocabDatabaseSchema.concept c1
             ON ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
         WHERE ancestor_concept_id = 4040390
               AND Min_LEVELS_OF_SEPARATION = 1
        ) proc_by_os1

        INNER JOIN
        (SELECT
           max(c1.CONCEPT_ID) AS os1_concept_id,
           c2.concept_id      AS os2_concept_id,
           c2.concept_name    AS os2_concept_name
         FROM @vocabDatabaseSchema.concept_ancestor ca1
           INNER JOIN
           @vocabDatabaseSchema.concept c1
             ON ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
           INNER JOIN
           @vocabDatabaseSchema.concept_ancestor ca2
             ON c1.concept_id = ca2.ANCESTOR_CONCEPT_ID
           INNER JOIN
           @vocabDatabaseSchema.concept c2
             ON ca2.DESCENDANT_CONCEPT_ID = c2.concept_id
         WHERE ca1.ancestor_concept_id = 4040390
               AND ca1.Min_LEVELS_OF_SEPARATION = 1
               AND ca2.MIN_LEVELS_OF_SEPARATION = 1
         GROUP BY c2.concept_id, c2.concept_name
        ) proc_by_os2
          ON proc_by_os1.os1_concept_id = proc_by_os2.os1_concept_id

        INNER JOIN
        (SELECT
           max(c1.CONCEPT_ID) AS os2_concept_id,
           c2.concept_id      AS os3_concept_id,
           c2.concept_name    AS os3_concept_name
         FROM @vocabDatabaseSchema.concept_ancestor ca1
           INNER JOIN
           @vocabDatabaseSchema.concept c1
             ON ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
           INNER JOIN
           @vocabDatabaseSchema.concept_ancestor ca2
             ON c1.concept_id = ca2.ANCESTOR_CONCEPT_ID
           INNER JOIN
           @vocabDatabaseSchema.concept c2
             ON ca2.DESCENDANT_CONCEPT_ID = c2.concept_id
         WHERE ca1.ancestor_concept_id = 4040390
               AND ca1.Min_LEVELS_OF_SEPARATION = 2
               AND ca2.MIN_LEVELS_OF_SEPARATION = 1
         GROUP BY c2.concept_id, c2.concept_name
        ) proc_by_os3
          ON proc_by_os2.os2_concept_id = proc_by_os3.os2_concept_id
    ) proc_hierarchy
      ON ca1.ancestor_concept_id = proc_hierarchy.os3_concept_id
  GROUP BY procs.concept_id,
    procs.proc_concept_name;

select * into 
@resultsDatabaseSchema.concept_hierarchy
from
(
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from #ch_condition
  
  union all
  
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from #ch_drug
  
  union all 
  
  select
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from #ch_drug_era
  
  union all
  
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from #ch_measurement
  
  union all
  
  select
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from #ch_observation
  
  union all 
  
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from #ch_procedure
) Q
;

truncate table #ch_condition;
drop table #ch_condition;

truncate table #ch_drug;
drop table #ch_drug;

truncate table #ch_drug_era;
drop table #ch_drug_era;

truncate table #ch_measurement;
drop table #ch_measurement;

truncate table #ch_observation;
drop table #ch_observation;

truncate table #ch_procedure;
drop table #ch_procedure;

/********** CONDITION/CONDITION_ERA **********/

--HINT DISTRIBUTE_ON_KEY(concept_id)
  SELECT
    snomed.concept_id,
    snomed.concept_name AS concept_name,
    'Condition' AS treemap,
    null as concept_hierarchy_type,
    pt_to_hlt.pt_concept_name as level1_concept_name,
    hlt_to_hlgt.hlt_concept_name as level2_concept_name,
    hlgt_to_soc.hlgt_concept_name as level3_concept_name,
    soc.concept_name    AS level4_concept_name
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_condition
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

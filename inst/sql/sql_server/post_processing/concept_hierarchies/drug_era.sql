/********** DRUG_ERA **********/

--HINT DISTRIBUTE_ON_KEY(concept_id)
  SELECT
    rxnorm.rxnorm_ingredient_concept_id as concept_id,
    rxnorm.rxnorm_ingredient_concept_name as concept_name,
    'Drug Era' AS treemap,
    null as concept_hierarchy_type,
    atc5_to_atc3.atc5_concept_name as level1_concept_name,
    atc3_to_atc1.atc3_concept_name as level2_concept_name,
    atc1.concept_name as level3_concept_name,
    null as level4_concept_name
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_drug_era
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

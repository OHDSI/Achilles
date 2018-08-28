/********** OBSERVATION **********/

--HINT DISTRIBUTE_ON_KEY(concept_id)
  SELECT
    obs.concept_id,
    obs.concept_name,
    'Observation' AS treemap,
    null as concept_hierarchy_type,
    max(c1.concept_name) AS level1_concept_name,
    max(c2.concept_name) AS level2_concept_name,
    max(c3.concept_name) AS level3_concept_name,
    null as level4_concept_name
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_observation
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
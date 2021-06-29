IF OBJECT_ID('@resultsDatabaseSchema.achilles_result_concept_count', 'U') IS NOT NULL
  drop table @resultsDatabaseSchema.achilles_result_concept_count;

WITH concepts AS (
      SELECT
        CAST(ancestor_concept_id AS VARCHAR)   ancestor_id,
        CAST(descendant_concept_id AS VARCHAR) descendant_id
      FROM @vocabDatabaseSchema.concept_ancestor ca
      UNION
      SELECT
        CAST(concept_id AS VARCHAR) ancestor_id,
        CAST(concept_id AS VARCHAR) descendant_id
      FROM @vocabDatabaseSchema.concept c
  ), counts AS (
  SELECT stratum_1 concept_id, MAX (count_value) agg_count_value
  FROM @resultsDatabaseSchema.achilles_results
  WHERE analysis_id IN (2, 4, 5, 201, 225, 301, 325, 401, 425, 501, 505, 525, 601, 625, 701, 725, 801, 825,
  826, 827, 901, 1001, 1201, 1203, 1425, 1801, 1825, 1826, 1827, 2101, 2125, 2301)
  GROUP BY stratum_1
  UNION
  SELECT stratum_2 AS concept_id, SUM (count_value) AS agg_count_value
  FROM @resultsDatabaseSchema.achilles_results
  WHERE analysis_id IN (405, 605, 705, 805, 807, 1805, 1807, 2105)
  GROUP BY stratum_2
  ), counts_person AS (
  SELECT stratum_1 concept_id, MAX (count_value) agg_count_value
  FROM @resultsDatabaseSchema.achilles_results
  WHERE analysis_id IN (200, 400, 600, 700, 800, 900, 1000, 1300, 1800, 2100, 2200)
  GROUP BY stratum_1)

select @fieldNames
into @resultsDatabaseSchema.achilles_result_concept_count
from
(
  SELECT
    concepts.ancestor_id               concept_id,
    isnull(max(c1.agg_count_value), 0) record_count,
    isnull(sum(c2.agg_count_value), 0) descendant_record_count,
    isnull(max(c3.agg_count_value), 0) person_count,
    isnull(sum(c4.agg_count_value), 0) descendant_person_count
  FROM concepts
    LEFT JOIN counts c1 ON concepts.ancestor_id = c1.concept_id
    LEFT JOIN counts c2 ON concepts.descendant_id = c2.concept_id
    LEFT JOIN counts_person c3 ON concepts.ancestor_id = c3.concept_id
    LEFT JOIN counts_person c4 ON concepts.descendant_id = c4.concept_id
  GROUP BY concepts.ancestor_id
) Q
;

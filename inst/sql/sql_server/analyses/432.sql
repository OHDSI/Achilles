-- 432	Number of persons by condition start date decade (YYYY), by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
    condition_concept_id as stratum_1,
    FLOOR(YEAR(condition_start_date)/10)*10 as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.condition_occurrence
  GROUP BY condition_concept_id,
    FLOOR(YEAR(condition_start_date)/10)*10
)
SELECT
  432 as analysis_id,
  cast(stratum_1 as varchar(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_432
FROM rawData;

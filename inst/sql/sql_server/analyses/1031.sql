-- 1031	Number of persons by condition era start date (YYYYMMDD), by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
    condition_concept_id as stratum_1,
	(YEAR(condition_era_start_date)*100 + MONTH(condition_era_start_date))*100 + DAY(condition_era_start_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  FROM
  @cdmDatabaseSchema.condition_era
  GROUP BY condition_concept_id,
    (YEAR(condition_era_start_date)*100 + MONTH(condition_era_start_date))*100 + DAY(condition_era_start_date)
)
SELECT
  1031 as analysis_id,
  cast(stratum_1 as varchar(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1031
FROM rawData;
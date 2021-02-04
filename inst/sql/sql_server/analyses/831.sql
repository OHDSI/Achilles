-- 831	Number of persons by observation date (YYYYMMDD), by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
    CAST(observation_concept_id AS VARCHAR(255)) as stratum_1,
	(YEAR(observation_date)*100 + MONTH(observation_date))*100 + DAY(observation_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  FROM
  @cdmDatabaseSchema.observation
  GROUP BY observation_concept_id,
	(YEAR(observation_date)*100 + MONTH(observation_date))*100 + DAY(observation_date)
)
SELECT
  831 as analysis_id,
  cast(stratum_1 as varchar(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_831
FROM rawData;

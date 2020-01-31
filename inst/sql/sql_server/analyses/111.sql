-- 111	Number of persons by observation period start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(observation_period_start_date)*100 + month(OBSERVATION_PERIOD_START_DATE) as stratum_1,
    COUNT_BIG(distinct op1.PERSON_ID) as count_value
  from
    @cdmDatabaseSchema.observation_period op1
  group by YEAR(observation_period_start_date)*100 + month(OBSERVATION_PERIOD_START_DATE)
)
SELECT
  111 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_111
FROM rawData;

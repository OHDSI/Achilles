-- 420	Number of condition occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(co1.condition_start_date)*100 + month(co1.condition_start_date) as stratum_1,
    COUNT_BIG(co1.PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.condition_occurrence co1 inner join 
  @cdmDatabaseSchema.observation_period op on co1.person_id = op.person_id
  -- only include events that occur during observation period
  where co1.condition_start_date <= op.observation_period_end_date and
  isnull(co1.condition_end_date,co1.condition_start_date) >= op.observation_period_start_date
  
  group by YEAR(co1.condition_start_date)*100 + month(co1.condition_start_date)
)
SELECT
  420 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_420
FROM rawData;

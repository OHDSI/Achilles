-- 820	Number of observation records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(o1.observation_date)*100 + month(o1.observation_date) as stratum_1,
    COUNT_BIG(o1.PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.observation o1 inner join 
  @cdmDatabaseSchema.observation_period op on o1.person_id = op.person_id
  -- only include events that occur during observation period
  where o1.observation_date <= op.observation_period_end_date and
  o1.observation_date >= op.observation_period_start_date
  
  group by YEAR(o1.observation_date)*100 + month(o1.observation_date)
)
SELECT
  820 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_820
FROM rawData;

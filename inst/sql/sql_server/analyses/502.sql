-- 502	Number of persons by death month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(d1.death_date)*100 + month(d1.death_date) as stratum_1,
    COUNT_BIG(distinct d1.PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.death d1 inner join 
  @cdmDatabaseSchema.observation_period op on d1.person_id = op.person_id
  -- only include events that occur during observation period
  where d1.death_date <= op.observation_period_end_date and
  isnull(d1.death_date,d1.death_date) >= op.observation_period_start_date
  
  group by YEAR(d1.death_date)*100 + month(d1.death_date)
)
SELECT
  502 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_502
FROM rawData;
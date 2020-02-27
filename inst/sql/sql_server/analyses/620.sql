-- 620	Number of procedure occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(po1.procedure_date)*100 + month(po1.procedure_date) as stratum_1,
    COUNT_BIG(po1.PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.procedure_occurrence po1 inner join 
  @cdmDatabaseSchema.observation_period op on po1.person_id = op.person_id
  -- only include events that occur during observation period
  where po1.procedure_date <= op.observation_period_end_date and
  po1.procedure_date >= op.observation_period_start_date
  
  group by YEAR(po1.procedure_date)*100 + month(po1.procedure_date)
)
SELECT
  620 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_620
FROM rawData;

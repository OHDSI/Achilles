-- 202	Number of persons by visit occurrence start month, by visit_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    vo1.visit_concept_id as stratum_1,
    YEAR(vo1.visit_start_date)*100 + month(vo1.visit_start_date) as stratum_2,
    COUNT_BIG(distinct vo1.PERSON_ID) as count_value
  from
    @cdmDatabaseSchema.visit_occurrence vo1 inner join 
  @cdmDatabaseSchema.observation_period op on vo1.person_id = op.person_id
  -- only include events that occur during observation period
  where vo1.visit_start_date <= op.observation_period_end_date and
  isnull(vo1.visit_end_date,vo1.visit_start_date) >= op.observation_period_start_date
  
  group by vo1.visit_concept_id,
    YEAR(vo1.visit_start_date)*100 + month(vo1.visit_start_date)
)
SELECT
  202 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_202
FROM rawData;

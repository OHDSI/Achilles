-- 204	Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    vo1.visit_concept_id as stratum_1,
    YEAR(vo1.visit_start_date) as stratum_2,
    p1.gender_concept_id as stratum_3,
    floor((year(vo1.visit_start_date) - p1.year_of_birth)/10) as stratum_4,
    COUNT_BIG(distinct p1.PERSON_ID) as count_value
  from @cdmDatabaseSchema.person p1
  inner join
  @cdmDatabaseSchema.visit_occurrence vo1
  on p1.person_id = vo1.person_id
  inner join 
  @cdmDatabaseSchema.observation_period op on vo1.person_id = op.person_id
  -- only include events that occur during observation period
  where vo1.visit_start_date <= op.observation_period_end_date and
  isnull(vo1.visit_end_date,vo1.visit_start_date) >= op.observation_period_start_date
  
  
  group by vo1.visit_concept_id,
    YEAR(vo1.visit_start_date),
    p1.gender_concept_id,
    floor((year(vo1.visit_start_date) - p1.year_of_birth)/10)
)
SELECT
  204 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(stratum_3 as varchar(255)) as stratum_3,
  cast(stratum_4 as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_204
FROM rawData;

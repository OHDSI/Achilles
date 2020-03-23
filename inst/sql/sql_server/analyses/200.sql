-- 200	Number of persons with at least one visit occurrence, by visit_concept_id
-- restricted to visits overlapping with observation period

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 200 as analysis_id, 
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct vo1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_200
from
	@cdmDatabaseSchema.visit_occurrence vo1 inner join 
  @cdmDatabaseSchema.observation_period op on vo1.person_id = op.person_id
  -- only include events that occur during observation period
  where vo1.visit_start_date <= op.observation_period_end_date and
  isnull(vo1.visit_end_date,vo1.visit_start_date) >= op.observation_period_start_date
group by vo1.visit_concept_id
;

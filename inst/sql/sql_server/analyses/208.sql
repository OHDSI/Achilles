--208	Number of visit records outside valid observation period

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 208 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(vo1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_208
from
	@cdmDatabaseSchema.visit_occurrence vo1
	left join @cdmDatabaseSchema.observation_period op1
	on op1.person_id = vo1.person_id
	and vo1.visit_start_date >= op1.observation_period_start_date
	and vo1.visit_start_date <= op1.observation_period_end_date
where op1.person_id is null
;

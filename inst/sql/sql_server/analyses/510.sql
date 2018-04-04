-- 510	Number of death records outside valid observation period

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 510 as analysis_id, 
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(d1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_510
from
	@cdmDatabaseSchema.death d1
		left join @cdmDatabaseSchema.observation_period op1
		on d1.person_id = op1.person_id
		and d1.death_date >= op1.observation_period_start_date
		and d1.death_date <= op1.observation_period_end_date
where op1.person_id is null
;

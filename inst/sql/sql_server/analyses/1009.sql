-- 1009	Number of condition eras outside valid observation period

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1009 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1009
from
	@cdmDatabaseSchema.condition_era ce1
	left join @cdmDatabaseSchema.observation_period op1
	on op1.person_id = ce1.person_id
	and ce1.condition_era_start_date >= op1.observation_period_start_date
	and ce1.condition_era_start_date <= op1.observation_period_end_date
where op1.person_id is null
;

-- 1009	Number of condition eras outside valid observation period


select 1009 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1009
from
	@cdmDatabaseSchema.condition_era ce1
	left join @cdmDatabaseSchema.observation_period op1
	on op1.person_id = ce1.person_id
	and ce1.condition_era_start_datetime >= op1.observation_period_start_date
	and ce1.condition_era_start_datetime <= op1.observation_period_end_date
where op1.person_id is null
;

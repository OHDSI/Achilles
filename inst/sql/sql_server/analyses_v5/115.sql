-- 115	Number of persons with observation period end < start

select 115 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_115
from
	@cdmDatabaseSchema.observation_period op1
where op1.observation_period_end_date < op1.observation_period_start_date
;

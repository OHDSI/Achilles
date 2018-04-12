-- 115	Number of persons with observation period end < start

select 115 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_115
from
	@cdmDatabaseSchema.observation_period op1
where op1.observation_period_end_date < op1.observation_period_start_date
;

-- 1415	Number of persons with payer plan period end < start

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1415 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(ppp1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1415
from
	@cdmDatabaseSchema.payer_plan_period ppp1
where ppp1.payer_plan_period_end_date < ppp1.payer_plan_period_start_date
;

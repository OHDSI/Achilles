-- 1412	Number of persons by payer plan period end month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1412 as analysis_id,  
	DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_start_date), 1) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1412
from
	@cdmDatabaseSchema.PERSON p1
	inner join @cdmDatabaseSchema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
group by DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_start_date), 1)
;

-- 1412	Number of persons by payer plan period end month

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1412 as analysis_id,  
	cast(CONCAT(cast(YEAR(payer_plan_period_end_date) as varchar(4)), CONCAT(RIGHT(CONCAT('0', CAST(month(payer_plan_period_end_DATE) AS VARCHAR(2))), 2), '01')) as VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1412
from
	@cdmDatabaseSchema.PERSON p1
	inner join @cdmDatabaseSchema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
group by cast(CONCAT(cast(YEAR(payer_plan_period_end_date) as varchar(4)), CONCAT(RIGHT(CONCAT('0', CAST(month(payer_plan_period_end_DATE) AS VARCHAR(2))), 2), '01')) as VARCHAR(255))
;

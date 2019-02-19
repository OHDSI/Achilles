-- 1408	Number of persons by length of payer plan period, in 30d increments

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1408 as analysis_id,  
	CAST(floor(DATEDIFF(dd, ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)/30) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1408
from @cdmDatabaseSchema.person p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from @cdmDatabaseSchema.payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
group by CAST(floor(DATEDIFF(dd, ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)/30) AS VARCHAR(255))
;

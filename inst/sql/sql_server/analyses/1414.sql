-- 1414	Number of persons with payer plan period before year-of-birth

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1414 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1414
from
	@cdmDatabaseSchema.PERSON p1
	inner join (select person_id, MIN(year(payer_plan_period_start_date)) as first_obs_year from @cdmDatabaseSchema.payer_plan_period group by PERSON_ID) ppp1
	on p1.person_id = ppp1.person_id
where p1.year_of_birth > ppp1.first_obs_year
;

-- 1414	Number of persons with payer plan period before year-of-birth


select 1414 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1414
from
	@cdmDatabaseSchema.person p1
	inner join (select person_id, MIN(year(payer_plan_period_start_date)) as first_obs_year from @cdmDatabaseSchema.payer_plan_period group by PERSON_ID) ppp1
	on p1.person_id = ppp1.person_id
where p1.year_of_birth > ppp1.first_obs_year
;

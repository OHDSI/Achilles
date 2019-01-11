-- 114	Number of persons with observation period before year-of-birth

select 114 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_114
from
	@cdmDatabaseSchema.person p1
	inner join (select person_id, MIN(year(OBSERVATION_period_start_date)) as first_obs_year from @cdmDatabaseSchema.observation_period group by PERSON_ID) op1
	on p1.person_id = op1.person_id
where p1.year_of_birth > op1.first_obs_year
;

-- 504	Number of persons with a death, by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 504 as analysis_id,   
	cast(year(O.observation_datetime) AS varchar(255)) as stratum_1,
	cast(P.gender_concept_id AS varchar(255)) as stratum_2,
	cast(floor((year(O.observation_datetime) - P.year_of_birth)/10) as varchar(255)) as stratum_3,
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	count_big(distinct O.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_504
from @cdmDatabaseSchema.observation O
join @cdmDatabaseSchema.person P on O.person_id = P.person_id
  and P.death_datetime = O.observation_datetime
where O.observation_concept_id = 4306655 -- death concept id
group by year(O.observation_datetime),
	P.gender_concept_id,
	floor((year(O.observation_datetime) - P.year_of_birth)/10)
;

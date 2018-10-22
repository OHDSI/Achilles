-- 502	Number of persons by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 502 as analysis_id,   
	cast(year(O.observation_datetime)*100 + month(O.observation_datetime) as varchar(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, 
	cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	count_big(distinct O.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_502
from @cdmDatabaseSchema.observation O
join @cdmDatabaseSchema.person P on O.person_id = P.person_id
  and P.death_datetime = O.observation_datetime
where O.observation_concept_id = 4306655 -- death concept id
group by year(O.observation_datetime)*100 + month(O.observation_datetime)
;
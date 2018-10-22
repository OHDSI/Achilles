-- 509	Number of death records with invalid person_id

--HINT DISTRIBUTE_ON_KEY(count_value)
select 509 as analysis_id, 
	cast(null as varchar(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, 
	cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	count_big(O.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_509
from @cdmDatabaseSchema.observation O
left join @cdmDatabaseSchema.person P on O.person_id = P.person_id
  and P.death_datetime = O.observation_datetime
where O.observation_concept_id = 4306655 -- death concept id
  and P.person_id is null
;
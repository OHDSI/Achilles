-- 510	Number of death records outside valid observation period

--HINT DISTRIBUTE_ON_KEY(count_value)
select 510 as analysis_id, 
	cast(null as varchar(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, 
	cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	count_big(O.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_510
from @cdmDatabaseSchema.observation O
join @cdmDatabaseSchema.person P on O.person_id = P.person_id
  and P.death_datetime = O.observation_datetime
left join @cdmDatabaseSchema.observation_period OP on O.person_id = OP.person_id
  and O.observation_datetime >= OP.observation_period_start_date
  and O.observation_datetime <= OP.observation_period_end_date
where O.observation_concept_id = 4306655 -- death concept id
  and OP.person_id is null
;

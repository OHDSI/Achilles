-- 500	Number of persons with death, by cause of death (condition_concept_id)

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 500 as analysis_id, 
	cast(C.condition_concept_id AS varchar(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, 
	cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	count_big(distinct O.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_500
from @cdmDatabaseSchema.observation O
join @cdmDatabaseSchema.person P on O.person_id = P.person_id
  and P.death_datetime = O.observation_datetime
left join @cdmDatabaseSchema.condition_occurrence C on C.person_id = O.person_id
  and P.death_datetime = C.condition_start_datetime
left join @cdmDatabaseSchema.concept CN on C.condition_type_concept_id = CN.concept_id
  and CN.concept_class_id = 'Death Type'
where O.observation_concept_id = 4306655 -- death concept id
group by C.condition_concept_id
;

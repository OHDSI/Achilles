-- 303	Number of provider records, by specialty_concept_id, visit_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 303 as analysis_id,
       cast(p.specialty_concept_id AS varchar(255)) AS stratum_1,
       cast(vo.visit_concept_id    AS varchar(255)) AS stratum_2,
       cast(null as varchar(255)) as stratum_3,
       cast(null as varchar(255)) as stratum_4,
       cast(null as varchar(255)) as stratum_5, 
       count_big(*) AS count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_303 
  from @cdmDatabaseSchema.provider p
  join @cdmDatabaseSchema.visit_occurrence vo
    on vo.provider_id = p.provider_id
 group by p.specialty_concept_id, visit_concept_id;
 
 

-- 225	Number of visit_occurrence records, by visit_source_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 225 as analysis_id,
       cast(visit_source_concept_id AS varchar(255)) AS stratum_1,
       cast(null AS varchar(255)) AS stratum_2,
       cast(null as varchar(255)) as stratum_3,
       cast(null as varchar(255)) as stratum_4,
       cast(null as varchar(255)) as stratum_5,
       count_big(*) AS count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_225 
  from @cdmDatabaseSchema.visit_occurrence
 group by visit_source_concept_id;

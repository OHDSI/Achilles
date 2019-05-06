-- 825	Number of observation records, by observation_source_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 825 as analysis_id,
       cast(observation_source_concept_id AS varchar(255)) AS stratum_1,
       cast(null AS varchar(255)) AS stratum_2,
       cast(null as varchar(255)) as stratum_3,
       cast(null as varchar(255)) as stratum_4,
       cast(null as varchar(255)) as stratum_5,
       count_big(*) AS count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_825 
  from @cdmDatabaseSchema.observation
 group by observation_source_concept_id;

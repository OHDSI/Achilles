-- 827	Number of observation records, by unit_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 827 as analysis_id, 
	   cast(unit_concept_id AS varchar(255)) as stratum_1,
	   cast(null AS varchar(255)) as stratum_2,
	   cast(null as varchar(255)) as stratum_3, 
	   cast(null as varchar(255)) as stratum_4, 
	   cast(null as varchar(255)) as stratum_5,
	   count_big(*) as count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_827
  from @cdmDatabaseSchema.observation
 group by unit_concept_id;
 
 
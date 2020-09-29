-- 1203	Number of visits by place of service discharge type

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1203 as analysis_id,  
       cast(discharge_to_concept_id AS VARCHAR(255)) as stratum_1, 
       cast(null as varchar(255)) as stratum_2, 
       cast(null as varchar(255)) as stratum_3, 
       cast(null as varchar(255)) as stratum_4, 
       cast(null as varchar(255)) as stratum_5,
       COUNT_BIG(*) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1203
from @cdmDatabaseSchema.visit_occurrence
where discharge_to_concept_id != 0
group by discharge_to_concept_id;

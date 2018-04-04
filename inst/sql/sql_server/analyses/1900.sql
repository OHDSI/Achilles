-- 1900	concept_0 report

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1900 as analysis_id, CAST(table_name AS VARCHAR(255)) as stratum_1, source_value as stratum_2, 
null as stratum_3, null as stratum_4, null as stratum_5,
cnt as count_value
 into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1900
 from (
select 'measurement' as table_name,measurement_source_value as source_value, COUNT_BIG(*) as cnt from @cdmDatabaseSchema.measurement where measurement_concept_id = 0 group by measurement_source_value 
union
select 'procedure_occurrence' as table_name,procedure_source_value as source_value, COUNT_BIG(*) as cnt from @cdmDatabaseSchema.procedure_occurrence where procedure_concept_id = 0 group by procedure_source_value 
union
select 'drug_exposure' as table_name,drug_source_value as source_value, COUNT_BIG(*) as cnt from @cdmDatabaseSchema.drug_exposure where drug_concept_id = 0 group by drug_source_value 
union
select 'condition_occurrence' as table_name,condition_source_value as source_value, COUNT_BIG(*) as cnt from @cdmDatabaseSchema.condition_occurrence where condition_concept_id = 0 group by condition_source_value 
) a
where cnt >= 1 --use other threshold if needed (e.g., 10)
--order by a.table_name desc, cnt desc
;

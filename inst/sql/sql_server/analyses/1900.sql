-- 1900	concept_0 report

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1900 as analysis_id, cast(table_name as varchar(255)) as stratum_1, source_value as stratum_2, 
cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
cnt as count_value
 into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1900
 from (
select 'measurement'           as table_name, measurement_source_value  as source_value, count_big(*) as cnt from @cdmDatabaseSchema.measurement          where measurement_concept_id = 0  group by measurement_source_value 
union
select 'procedure_occurrence'  as table_name, procedure_source_value    as source_value, count_big(*) as cnt from @cdmDatabaseSchema.procedure_occurrence where procedure_concept_id = 0    group by procedure_source_value 
union
select 'drug_exposure'         as table_name, drug_source_value         as source_value, count_big(*) as cnt from @cdmDatabaseSchema.drug_exposure        where drug_concept_id = 0         group by drug_source_value 
union
select 'condition_occurrence'  as table_name, condition_source_value    as source_value, count_big(*) as cnt from @cdmDatabaseSchema.condition_occurrence where condition_concept_id = 0    group by condition_source_value 
union
select 'observation'           as table_name, observation_source_value  as source_value, count_big(*) as cnt from @cdmDatabaseSchema.observation          where observation_concept_id = 0  group by observation_source_value                  
{@cdmVersion not in ('5', '5.0', '5.0.0', '5.1', '5.1.0', '5.2', '5.2.0')}?{
union
select 'visit_detail'          as table_name, visit_detail_source_value as source_value, count_big(*) as cnt from @cdmDatabaseSchema.visit_detail         where visit_detail_concept_id = 0 group by visit_detail_source_value
}
union
select 'visit_occurrence'      as table_name, visit_source_value        as source_value, count_big(*) as cnt from @cdmDatabaseSchema.visit_occurrence     where visit_concept_id = 0        group by visit_source_value
union
select 'device_exposure'       as table_name, device_source_value       as source_value, count_big(*) as cnt from @cdmDatabaseSchema.device_exposure      where device_concept_id = 0       group by device_source_value
union
select 'death'                 as table_name, cause_source_value        as source_value, count_big(*) as cnt from @cdmDatabaseSchema.death                where cause_concept_id = 0        group by cause_source_value
) a
where cnt >= 1 --use other threshold if needed (e.g., 10)
--order by a.table_name desc, cnt desc
;

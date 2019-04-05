-- 1900	concept_0 report

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1900 as analysis_id, cast(table_name as varchar(255)) as stratum_1, source_value as stratum_2, 
cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
cnt as count_value
 into @scratchdatabaseschema@schemadelim@tempachillesprefix_1900
 from (
select 'measurement'           as table_name, measurement_source_value  as source_value, count_big(*) as cnt from @cdmdatabaseschema.measurement          where measurement_concept_id = 0  group by measurement_source_value 
union
select 'procedure_occurrence'  as table_name, procedure_source_value    as source_value, count_big(*) as cnt from @cdmdatabaseschema.procedure_occurrence where procedure_concept_id = 0    group by procedure_source_value 
union
select 'drug_exposure'         as table_name, drug_source_value         as source_value, count_big(*) as cnt from @cdmdatabaseschema.drug_exposure        where drug_concept_id = 0         group by drug_source_value 
union
select 'condition_occurrence'  as table_name, condition_source_value    as source_value, count_big(*) as cnt from @cdmdatabaseschema.condition_occurrence where condition_concept_id = 0    group by condition_source_value 
union
select 'observation'           as table_name, observation_source_value  as source_value, count_big(*) as cnt from @cdmdatabaseschema.observation          where observation_concept_id = 0  group by observation_source_value                  
union
select 'visit_detail'          as table_name, visit_detail_source_value as source_value, count_big(*) as cnt from @cdmdatabaseschema.visit_detail         where visit_detail_concept_id = 0 group by visit_detail_source_value
union
select 'visit_occurrence'      as table_name, visit_source_value        as source_value, count_big(*) as cnt from @cdmdatabaseschema.visit_occurrence     where visit_concept_id = 0        group by visit_source_value
union
select 'device_exposure'       as table_name, device_source_value       as source_value, count_big(*) as cnt from @cdmdatabaseschema.device_exposure      where device_concept_id = 0       group by device_source_value
union
select 'death'                 as table_name, cause_source_value        as source_value, count_big(*) as cnt from @cdmdatabaseschema.death                where cause_concept_id = 0        group by cause_source_value
) a
where cnt >= 1 --use other threshold if needed (e.g., 10)
--order by a.table_name desc, cnt desc
;

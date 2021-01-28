-- 226	Number of records by domain by visit concept id

select 226 as analysis_id, 
	CAST(v.visit_concept_id AS VARCHAR(255)) as stratum_1,
	v.cdm_table as stratum_2,
	cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	v.record_count as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_226
from (
  select 'drug_exposure' cdm_table, coalesce(visit_concept_id,0) visit_concept_id, count(*) record_count
  from @cdmDatabaseSchema.drug_exposure t
  left join @cdmDatabaseSchema.visit_occurrence v on t.visit_occurrence_id = v.visit_occurrence_id
  group by visit_concept_id
  union
  select 'condition_occurrence' cdm_table, coalesce(visit_concept_id,0) visit_concept_id, count(*) record_count
  from @cdmDatabaseSchema.condition_occurrence t
  left join @cdmDatabaseSchema.visit_occurrence v on t.visit_occurrence_id = v.visit_occurrence_id
  group by visit_concept_id
  union
  select 'device_exposure' cdm_table, coalesce(visit_concept_id,0) visit_concept_id, count(*) record_count
  from @cdmDatabaseSchema.device_exposure t
  left join @cdmDatabaseSchema.visit_occurrence v on t.visit_occurrence_id = v.visit_occurrence_id
  group by visit_concept_id
  union
  select 'procedure_occurrence' cdm_table, coalesce(visit_concept_id,0) visit_concept_id, count(*) record_count
  from @cdmDatabaseSchema.procedure_occurrence t
  left join @cdmDatabaseSchema.visit_occurrence v on t.visit_occurrence_id = v.visit_occurrence_id
  group by visit_concept_id
  union
  select 'measurement' cdm_table, coalesce(visit_concept_id,0) visit_concept_id, count(*) record_count
  from @cdmDatabaseSchema.measurement t
  left join @cdmDatabaseSchema.visit_occurrence v on t.visit_occurrence_id = v.visit_occurrence_id
  group by visit_concept_id
  union
  select 'observation' cdm_table, coalesce(visit_concept_id,0) visit_concept_id, count(*) record_count
  from @cdmDatabaseSchema.observation t
  left join @cdmDatabaseSchema.visit_occurrence v on t.visit_occurrence_id = v.visit_occurrence_id
  group by visit_concept_id
) v
;

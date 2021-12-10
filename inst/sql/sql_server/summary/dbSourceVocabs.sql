-- Gets a list of the source vocabularies present in an OMOP CDM instance
select c.cdm_source_name,
       c.cdm_source_abbreviation,
       t1.vocabulary_id
	     
from @cdm_database_schema.cdm_source c,

(
    select distinct vocabulary_id
    from @cdm_database_schema.condition_occurrence a
    join @cdm_database_schema.concept c
      on a.condition_source_concept_id = c.concept_id
      
    union 
    
    select distinct vocabulary_id
    from @cdm_database_schema.procedure_occurrence a
    join @cdm_database_schema.concept c
      on a.procedure_source_concept_id = c.concept_id
      
    union
    
    select distinct vocabulary_id
    from @cdm_database_schema.drug_exposure a
    join @cdm_database_schema.concept c
      on a.drug_source_concept_id = c.concept_id
      
    union
    
    select distinct vocabulary_id
    from @cdm_database_schema.measurement a
    join @cdm_database_schema.concept c
      on a.measurement_source_concept_id = c.concept_id
    
    union
    
    select distinct vocabulary_id
    from @cdm_database_schema.device_exposure a
    join @cdm_database_schema.concept c
      on a.device_source_concept_id = c.concept_id
      
    union
    
    select distinct vocabulary_id
    from @cdm_database_schema.observation a
    join @cdm_database_schema.concept c
      on a.observation_source_concept_id = c.concept_id
  ) t1
;

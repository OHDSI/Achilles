/*********************************************************************/
/***** Create hierarchy lookup table for the treemap hierarchies *****/
/*********************************************************************/
IF OBJECT_ID('@resultsDatabaseSchema.concept_hierarchy', 'U') IS NOT NULL
  DROP TABLE @resultsDatabaseSchema.concept_hierarchy;


--HINT DISTRIBUTE_ON_KEY(concept_id)
select * into 
@resultsDatabaseSchema.concept_hierarchy
from
(
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_condition
  
  union all
  
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_drug
  
  union all 
  
  select
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_drug_era
  
  union all
  
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_measurement
  
  union all
  
  select
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_observation
  
  union all 
  
  select 
  concept_id,
  cast(concept_name as VARCHAR(400)) as concept_name,
  cast(treemap as VARCHAR(20)) as treemap,
  cast(concept_hierarchy_type as VARCHAR(20)) as concept_hierarchy_type,
  cast(level1_concept_name as VARCHAR(255)) as level1_concept_name,
  cast(level2_concept_name as VARCHAR(255)) as level2_concept_name,
  cast(level3_concept_name as VARCHAR(255)) as level3_concept_name,
  cast(level4_concept_name as VARCHAR(255)) as level4_concept_name
  from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_procedure
) Q
;

drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_condition;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_drug;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_drug_era;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_measurement;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_observation;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_ch_procedure;

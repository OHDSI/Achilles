IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw', 'U') IS NOT NULL
	DROP TABLE @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw;

{@cdmVersion == '5'}?{
  --HINT DISTRIBUTE_ON_KEY(cost_event_id) 
  select 
    @domainId_id as cost_event_id,
    @costColumns
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_rawCost
  from @cdmDatabaseSchema.@domainId_cost
  ;
}:{
  --HINT DISTRIBUTE_ON_KEY(cost_event_id) 
  select  
    cost_event_id,
    @costColumns
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_rawCost
  from @cdmDatabaseSchema.cost
  where cost_domain_id = '@domainId'
  ;
}

--HINT DISTRIBUTE_ON_KEY(subject_id) 
select 
  B.@domainId_concept_id as subject_id,
  @costColumns
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw
from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_rawCost A
join @cdmDatabaseSchema.@domainTable B 
  on A.cost_event_id = B.@domainTable_id and B.@domainId_concept_id <> 0
;

truncate table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_rawCost;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_rawCost;

--ruleid 41 DQ rule, data density
--porting a Sentinel rule that checks for certain vital signs data (weight, in this case)
--multiple concepts_ids may be added to broaden the rule, however standardizing on a single
--concept would be more optimal
select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select 
    null as analysis_id,
    CAST('NOTIFICATION:No body weight data in MEASUREMENT table (under concept_id 3025315 (LOINC code 29463-7))' AS VARCHAR(255)) as achilles_heel_warning,
    41 as rule_id,
    null as record_count
  from
  (
    select count(*) as row_present  
    from @resultsDatabaseSchema.ACHILLES_results 
    where analysis_id = 1800 and stratum_1 = '3025315'
  ) a
  where a.row_present = 0
) Q
;
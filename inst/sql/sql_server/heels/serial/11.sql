--rule32 DQ rule
--uses iris: patients with at least one visit visit 
--does 100-THE IRIS MEASURE to check for percentage of patients with no visits

select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
FROM 
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select 
    null as analysis_id,
    CAST('NOTIFICATION: Percentage of patients with no visits exceeds threshold' AS VARCHAR(255)) as achilles_heel_warning,
    32 as rule_id,
    null as record_count
  from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId d
  where d.measure_id = 'ach_2003:Percentage'
  and 100 - d.statistic_value > 27  --threshold identified in the DataQuality study
) Q
;
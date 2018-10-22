--rule32 DQ rule
--uses iris: patients with at least one visit visit 
--does 100-THE IRIS MEASURE to check for percentage of patients with no visits

select *
into #serial_hr_@hrNewId
FROM 
(
  select * from #serial_hr_@hrOldId
  
  union all
  
  select 
    cast(null as int) as analysis_id,
    CAST('NOTIFICATION: Percentage of patients with no visits exceeds threshold' AS VARCHAR(255)) as achilles_heel_warning,
    32 as rule_id,
    cast(null as bigint) as record_count
  from #serial_rd_@rdOldId d
  where d.measure_id = 'ach_2003:Percentage'
  and 100 - d.statistic_value > 27  --threshold identified in the DataQuality study
) Q
;
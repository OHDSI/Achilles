--actual rule27
  
select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_achilles_heel_results_0
  
  union all
  
  SELECT 
    null as analysis_id,
    CAST(CONCAT('NOTIFICATION:Unmapped data over percentage threshold in:', 
    cast(d.stratum_1 as varchar)) AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    27 as rule_id,
    null as record_count
  FROM @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId d
  where d.measure_id = 'UnmappedData:byDomain:Percentage'
  and d.statistic_value > 0.1  --thresholds will be decided in the ongoing DQ-Study2
) Q
;

--end of rule27

--ruleid 44 DQ rule
--uses iris measure: patients with at least 1 Meas, 1 Dx and 1 Rx 


select 
  null as analysis_id,
  achilles_heel_warning,
  rule_id,
  null as record_count
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  SELECT 
    CAST('NOTIFICATION: Percentage of patients with at least 1 Measurement, 1 Dx and 1 Rx is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    44 as rule_id
  FROM @resultsDatabaseSchema.ACHILLES_results_derived d
  where d.measure_id = 'ach_2002:Percentage'
  and d.statistic_value < @ThresholdMinimalPtMeasDxRx  --threshold identified in the DataQuality study
) Q
;
--ruleid 44 DQ rule
--uses iris measure: patients with at least 1 Meas, 1 Dx and 1 Rx 

select *
into #serial_hr_@hrNewId
from
(
  select * from #serial_hr_@hrOldId
  
  union all
  
  SELECT 
    cast(null as int) as analysis_id,
    CAST('NOTIFICATION: Percentage of patients with at least 1 Measurement, 1 Dx and 1 Rx is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    44 as rule_id,
    cast(null as bigint) as record_count
  FROM #serial_rd_@rdOldId d
  where d.measure_id = 'ach_2002:Percentage'
  and d.statistic_value < @ThresholdMinimalPtMeasDxRx  --threshold identified in the DataQuality study
) Q
;
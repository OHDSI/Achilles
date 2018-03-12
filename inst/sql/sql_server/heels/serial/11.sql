--actual rule

select 
  null as analysis_id,
  achilles_heel_warning,
  rule_id,
  null as record_count
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  SELECT 
   CAST('NOTIFICATION:[PLAUSIBILITY] database has too few providers defined (given the total patient number)' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    31 as rule_id
  FROM @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId d
  where d.measure_id = 'Provider:PatientProviderRatio'
  and d.statistic_value > 10000  --thresholds will be decided in the ongoing DQ-Study2
) Q
;
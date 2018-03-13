--actual rule27
  
select 
  achilles_heel_warning,
  rule_id,
  null as record_count
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  SELECT 
   CAST(CONCAT('NOTIFICATION:Unmapped data over percentage threshold in:', cast(d.stratum_1 as varchar)) AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    27 as rule_id
  FROM @scratchDatabaseSchema@schemaDelim@heelPrefix_stg_achilles_results_derived d
  where d.measure_id = 'UnmappedData:byDomain:Percentage'
  and d.statistic_value > 0.1  --thresholds will be decided in the ongoing DQ-Study2
) Q;

--end of rule27

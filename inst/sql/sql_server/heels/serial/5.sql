select 
  null as analysis_id,
  stratum_1,
  null as stratum_2,
  statistic_value,
  measure_id
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
from
(
  select
    CAST(100.0 * 
      (select statistic_value from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId 
      where measure_id like 'UnmappedData:ach_1801:GlobalRowCnt')/statistic_value as FLOAT) as statistic_value,
    CAST('Measurement' AS VARCHAR(255)) as stratum_1, 
    CAST('UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId
  where measure_id = 'ach_1801:GlobalRowCnt'
) Q
;
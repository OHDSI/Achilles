select 
  null as analysis_id,
  stratum_1,
  null as stratum_2,
  statistic_value,
  measure_id
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId;
from
(
  select
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST('Observation' AS VARCHAR(255)) as stratum_1, 
    CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId
  join (select statistic_value as val 
  from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId where measure_id ='UnmappedData:ach_801:GlobalRowCnt') as st
  where measure_id = 'ach_801:GlobalRowCnt'
) Q
;
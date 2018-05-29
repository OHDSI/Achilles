select *
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdNewId
from
(

  select * from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdOldId
  
  union all
  
  select
    null as analysis_id,
    CAST('Measurement' AS VARCHAR(255)) as stratum_1, 
    null as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST(  'UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdOldId A
  join (select statistic_value as val from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdOldId 
        where measure_id = 'UnmappedData:ach_1801:GlobalRowCnt') as st
    on A.statistic_value = st.val
  where measure_id ='ach_1801:GlobalRowCnt'
  
) Q
;
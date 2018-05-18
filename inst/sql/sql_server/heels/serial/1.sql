select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
from
(

  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_achilles_results_derived_0
  
  union all
  
  select
    null as analysis_id,
    CAST('Condition' AS VARCHAR(255)) as stratum_1, 
    null as stratum_2,
    CAST(100.0*st.val/statistic_value AS FLOAT) as statistic_value,
    CAST('UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from @scratchDatabaseSchema@schemaDelim@heelPrefix_achilles_results_derived_0
  cross join (select statistic_value as val from @scratchDatabaseSchema@schemaDelim@heelPrefix_achilles_results_derived_0 
      where measure_id like 'UnmappedData:ach_401:GlobalRowCnt') as st
  where measure_id = 'ach_401:GlobalRowCnt'
) Q
;

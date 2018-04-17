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
    CAST(100.0 * 
      (select statistic_value from @scratchDatabaseSchema@schemaDelim@heelPrefix_achilles_results_derived_0
      where measure_id like 'UnmappedData:ach_401:GlobalRowCnt')/statistic_value as FLOAT) as statistic_value,
    CAST('UnmappedData:byDomain:Percentage' AS VARCHAR(255)) as measure_id
  from @scratchDatabaseSchema@schemaDelim@heelPrefix_achilles_results_derived_0
  where measure_id = 'ach_401:GlobalRowCnt'
) Q
;

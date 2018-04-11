--rule34 DQ rule
--NOTIFICATION: number of unmapped source values exceeds threshold
--related to rule 27 that looks at percentage of unmapped rows (rows as focus)
--this rule is looking at source values (as focus)


select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select
    null as analysis_id,
    CAST(CONCAT('NOTIFICATION: Count of unmapped source values exceeds threshold in: ', cast(stratum_1 as varchar)) AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    34 as rule_id,
    cast(statistic_value as int) as record_count
  FROM @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId d
  where measure_id = 'UnmappedDataByDomain:SourceValueCnt'
  and statistic_value > 1000 --threshold will be decided in DQ study 2
) Q
;
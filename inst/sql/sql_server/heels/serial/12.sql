--rule33 DQ rule (for general population only)
--NOTIFICATION: database does not have all age 0-80 represented


select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select 
    null as analysis_id,
    CAST('NOTIFICATION: [GeneralPopulationOnly] Not all deciles represented at first observation' AS VARCHAR(255)) as achilles_heel_warning,
    33 as rule_id,
    null as record_count
  FROM @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId d
  where d.measure_id = 'AgeAtFirstObsByDecile:DecileCnt' 
  and d.statistic_value < 9  --we expect deciles 0,1,2,3,4,5,6,7,8 
) Q
;
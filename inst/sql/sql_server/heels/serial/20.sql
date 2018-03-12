--ruleid 39 DQ rule; Given lifetime record DQ assumption if more than 30k patients is born for every deceased patient
--the dataset may not be recording complete records for all senior patients in that year
--derived ratio measure Death:BornDeceasedRatio only exists for years where death data exist
--to avoid alerting on too early years such as 1925 where births exist but no deaths

select 
  null as analysis_id,
  achilles_heel_warning,
  rule_id,
  record_count
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select 
  CAST('NOTIFICATION: [GeneralPopulationOnly] In some years, number of deaths is too low considering the number of births (lifetime record DQ assumption)' AS VARCHAR(255))
   as achilles_heel_warning,
   39 as rule_id,
   year_cnt as record_count 
   from
   (select count(*) as year_cnt from @resultsDatabaseSchema.ACHILLES_results_derived 
   where measure_id =  'Death:BornDeceasedRatio' and statistic_value > 30000) a
  where a.year_cnt> 0
) Q
;
--rule31 DQ rule
--ratio of providers to total patients

--compute a derived reatio
--TODO if provider count is zero it will generate division by zero (not sure how dirrerent db engins will react)
select * into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId 
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId
  
  union all
  
  select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  1.0*(select count_value as total_pts from @resultsDatabaseSchema.achilles_results r where analysis_id =1)/count_value as statistic_value,
  'Provider:PatientProviderRatio' as measure_id
  from @resultsDatabaseSchema.achilles_results
  where analysis_id = 300
) Q
;

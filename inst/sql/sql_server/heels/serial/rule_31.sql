--rule31 DQ rule
--ratio of providers to total patients

--compute a derived ratio
--TODO if provider count is zero it will generate division by zero (not sure how dirrerent db engins will react)
select * into #serial_rd_@rdNewId 
from
(
  select * from #serial_rd_@rdOldId
  
  union all
  
  select 
    cast(null as int) as analysis_id,
    cast(null as varchar(255)) as stratum_1,
    cast(null as varchar(255)) as stratum_2,
    CAST(1.0*ct.total_pts/count_value AS FLOAT) as statistic_value, 
    CAST('Provider:PatientProviderRatio' AS VARCHAR(255)) as measure_id
  from @resultsDatabaseSchema.achilles_results
  cross join (select count_value as total_pts from @resultsDatabaseSchema.achilles_results r where analysis_id =1) ct
  where analysis_id = 300
) Q
;

--actual rule

select *
into #serial_hr_@hrNewId
from 
(
  select * from #serial_hr_@hrOldId
  
  union all
  
  select 
    cast(null as int) as analysis_id,
    CAST('NOTIFICATION:[PLAUSIBILITY] database has too few providers defined (given the total patient number)' AS VARCHAR(255)) as achilles_heel_warning,
    31 as rule_id,
    cast(null as bigint) as record_count
  from #serial_rd_@rdNewId d
  where d.measure_id = 'Provider:PatientProviderRatio'
  and d.statistic_value > 10000  --thresholds will be decided in the ongoing DQ-Study2
) Q
;

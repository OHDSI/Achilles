--ruleid 42 DQ rule
--Percentage of outpatient visits (concept_id 9202) is too low (for general population).
--This may indicate a dataset with mostly inpatient data (that may be biased and missing some EHR events)
--Threshold was decided as 10th percentile in empiric comparison of 12 real world datasets in the DQ-Study2

select *
into #serial_hr_@hrNewId
from
(
  select * from #serial_hr_@hrOldId
  
  union all
  
  select 
    cast(null as int) as analysis_id,
    CAST('NOTIFICATION: [GeneralPopulationOnly] Percentage of outpatient visits is below threshold' AS VARCHAR(255)) as achilles_heel_warning,
    42 as rule_id,
    cast(null as bigint) as record_count
  from
  (
    select 
      1.0*achilles_results.count_value/c1.count_value as outp_perc
    from @resultsDatabaseSchema.achilles_results
		cross join (select sum(count_value) as count_value from @resultsDatabaseSchema.achilles_results where analysis_id = 201) c1
	  where analysis_id = 201 and stratum_1='9202'
  ) d
  where d.outp_perc < @ThresholdOutpatientVisitPerc
) Q
;
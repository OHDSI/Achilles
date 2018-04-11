--ruleid 42 DQ rule
--Percentage of outpatient visits (concept_id 9202) is too low (for general population).
--This may indicate a dataset with mostly inpatient data (that may be biased and missing some EHR events)
--Threshold was decided as 10th percentile in empiric comparison of 12 real world datasets in the DQ-Study2

select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  select 
    null as analysis_id,
    CAST('NOTIFICATION: [GeneralPopulationOnly] Percentage of outpatient visits is below threshold' AS VARCHAR(255)) as achilles_heel_warning,
    42 as rule_id,
    null as record_count
  from
  (
    select 
      1.0*count_value/(select sum(count_value) from @resultsDatabaseSchema.achilles_results where analysis_id = 201)  as outp_perc  
    from @resultsDatabaseSchema.achilles_results where analysis_id = 201 and stratum_1 = '9202'
  ) d
  where d.outp_perc < @ThresholdOutpatientVisitPerc
) Q
;
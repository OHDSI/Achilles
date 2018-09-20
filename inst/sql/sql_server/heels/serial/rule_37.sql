--ruleid 37 DQ rule

--derived measure for this rule - ratio of notes over the number of visits

select * into #serial_rd_@rdNewId
from
(
  select * from #serial_rd_@rdOldId
  
  union all
  
  SELECT 
    cast(null as int) as analysis_id,
    cast(null as varchar(255)) as stratum_1,
    cast(null as varchar(255)) as stratum_2,
    CAST(1.0*c1.all_notes/1.0*c2.all_visits AS FLOAT) as statistic_value, 
    CAST(  'Note:NoteVisitRatio' AS VARCHAR(255)) as measure_id
  FROM (SELECT sum(count_value) as all_notes FROM	@resultsDatabaseSchema.achilles_results r WHERE analysis_id =2201 ) c1
  CROSS JOIN (SELECT sum(count_value) as all_visits FROM @resultsDatabaseSchema.achilles_results r WHERE  analysis_id =201 ) c2
) A
;

--one co-author of the DataQuality study suggested measuring data density on visit level (in addition to 
-- patient and dataset level)
--Assumption is that at least one data event (e.g., diagnisis, note) is generated for each visit
--this rule is testing that at least some notes exist (considering the number of visits)
--for datasets with zero notes the derived measure is null and rule does not fire at all
--possible elaboration of this rule include number of inpatient notes given number of inpatient visits
--current rule is on overall data density (for notes only) per visit level


select *
into #serial_hr_@hrNewId
from
(
  select * from #serial_hr_@hrOldId
  
  union all
  
  select
    cast(null as int) as analysis_id,
    CAST('NOTIFICATION: Notes data density is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    37 as rule_id,
    cast(statistic_value as int) as record_count
  FROM #serial_rd_@rdNewId d
  where measure_id = 'Note:NoteVisitRatio'
  and statistic_value < 0.01 --threshold will be decided in DataQuality study
) Q
;

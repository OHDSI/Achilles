--ruleid 37 DQ rule

--derived measure for this rule - ratio of notes over the number of visits

select * into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdOldId
  
  union all
  
  select 
    null as analysis_id,
    null as stratum_1,
    null as stratum_2,
    statistic_value,
    measure_id
  from
  (
    SELECT 1.0*(SELECT sum(count_value) as all_notes 
    FROM @resultsDatabaseSchema.achilles_results r 
    WHERE analysis_id =2201 )/1.0*(SELECT sum(count_value) as all_visits 
    FROM @resultsDatabaseSchema.achilles_results r WHERE  analysis_id =201 ) as statistic_value,
     'Note:NoteVisitRatio' as measure_id
  ) Q
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
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_hr_@hrOldId
  
  union all
  
  select
    null as analysis_id,
    CAST('NOTIFICATION: Notes data density is below threshold' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
    37 as rule_id,
    cast(statistic_value as int) as record_count
  FROM @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_serial_rd_@rdNewId d
  where measure_id = 'Note:NoteVisitRatio'
  and statistic_value < 0.01 --threshold will be decided in DataQuality study
) Q
;
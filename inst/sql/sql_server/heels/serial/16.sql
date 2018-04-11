--ruleid 37 DQ rule

--derived measure for this rule - ratio of notes over the number of visits

select * into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdOldId
  
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
--ruleid 37 DQ rule

--derived measure for this rule - ratio of notes over the number of visits

select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  statistic_value,
  measure_id
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
from
(
   SELECT CAST(1.0*c1.all_notes/1.0*c2.all_visits AS FLOAT) as statistic_value, CAST(  'Note:NoteVisitRatio' AS VARCHAR(255)) as measure_id
  FROM (SELECT sum(count_value) as all_notes FROM	@resultsDatabaseSchema.achilles_results r WHERE analysis_id =2201 ) c1
  JOIN (SELECT sum(count_value) as all_visits FROM @resultsDatabaseSchema.achilles_results r WHERE  analysis_id =201 ) c2;
) Q
;
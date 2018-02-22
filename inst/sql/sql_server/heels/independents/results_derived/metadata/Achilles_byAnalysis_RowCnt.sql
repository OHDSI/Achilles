select 
  null as analysis_id,
  analysis_id as stratum_1,
  null as stratum_2,
  COUNT_BIG(*) as statistic_value, 
  'Achilles:byAnalysis:RowCnt' as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results 
group by analysis_id
;

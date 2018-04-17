select 
  null as analysis_id,
  cast(analysis_id as varchar(255)) as stratum_1,
  null as stratum_2,
  COUNT_BIG(*) as statistic_value, 
  cast('Achilles:byAnalysis:RowCnt' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results 
group by analysis_id
;

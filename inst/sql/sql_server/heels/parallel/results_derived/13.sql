select 
  cast(null as int) as analysis_id,
  cast(r.analysis_id as varchar(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  COUNT_BIG(*) as statistic_value, 
  cast('Achilles:byAnalysis:RowCnt' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.achilles_results r
group by r.analysis_id
;

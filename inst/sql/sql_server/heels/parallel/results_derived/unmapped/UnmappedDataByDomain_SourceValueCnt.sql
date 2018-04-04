select 
  null as analysis_id,
  stratum_1,
  null as stratum_2,
  count(*) as statistic_value,
  cast('UnmappedDataByDomain:SourceValueCnt' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 1900 
group by stratum_1;

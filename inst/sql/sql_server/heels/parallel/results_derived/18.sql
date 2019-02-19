select 
  cast(null as int) as analysis_id,
  cast(null as varchar(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  count(*) as statistic_value, 
  cast('Procedure:ConceptCnt' as varchar(255)) as measure_id 
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.achilles_results where analysis_id = 601;

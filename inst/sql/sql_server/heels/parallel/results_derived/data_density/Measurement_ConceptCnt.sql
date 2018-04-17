select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  count(*) as statistic_value, 
  cast('Measurement:ConceptCnt' as varchar(255)) as measure_id 
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 1801;

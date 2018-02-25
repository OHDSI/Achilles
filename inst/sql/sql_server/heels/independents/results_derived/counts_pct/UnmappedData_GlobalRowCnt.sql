--concept_0 global row  Counts per domain
--this is numerator for percentage value of unmapped rows (per domain)
select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  count_value as statistic_value, 
       CAST(concat('UnmappedData:ach_',cast(analysis_id as VARCHAR),':GlobalRowCnt') as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results 
--TODO:stratum_1 is varchar and this comparison may fail on some db engines
--indeed, mysql got error, changed to a string comparison
where analysis_id in (401,601,701,801,1801) and stratum_1 = '0';

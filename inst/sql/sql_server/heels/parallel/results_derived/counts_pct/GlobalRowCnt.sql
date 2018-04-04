--total number of rows per domain
--this derived measure is used for later measure of % of unmapped rows
--this produces a total count of rows in condition table, procedure table etc.
--used as denominator in later measures

       
select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  sum(count_value) as statistic_value, 
       CAST(concat('ach_',CAST(analysis_id as VARCHAR),':GlobalRowCnt') as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results 
where analysis_id in (401,601,701,801,1801) group by analysis_id;

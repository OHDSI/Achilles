--age at first observation by decile
select analysis_id, stratum_1, stratum_2, sum(count_value) as statistic_value, measure_id
into #temp_0
from (
  select 
    null as analysis_id,
    cast(floor(cast(stratum_1 as int)/10) as varchar(255)) as stratum_1,
    null as stratum_2,
    count_value,
    cast('AgeAtFirstObsByDecile:PersonCnt' as varchar(255)) as measure_id
  from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 101
) Q
group by analysis_id, stratum_1, stratum_2, measure_id
;

--count whether all deciles from 0 to 8 are there  (has later a rule: if less the threshold, issue notification)
select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  count(*) as statistic_value,
 cast('AgeAtFirstObsByDecile:DecileCnt' as varchar(255)) as measure_id
into #temp_1
from #temp_0
where measure_id = 'AgeAtFirstObsByDecile:PersonCnt' 
and cast(stratum_1 as int) <=8;

select analysis_id, stratum_1, stratum_2, statistic_value, measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  select analysis_id, stratum_1, stratum_2, statistic_value, measure_id
  from #temp_0
  union all
  select analysis_id, stratum_1, stratum_2, statistic_value, measure_id
  from #temp_1
) A;

truncate table #temp_0;
drop table #temp_0;

truncate table #temp_1;
drop table #temp_1;

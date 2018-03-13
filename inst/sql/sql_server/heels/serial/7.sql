--rule28 DQ rule
--are all values (or more than threshold) in measurement table non numerical?
--(count of Measurment records with no numerical value is in analysis_id 1821)


select * into #tempResults
from 
(
  select 
  (select count_value from @resultsDatabaseSchema.achilles_results where analysis_id = 1821)*100.0/all_count as statistic_value,
  CAST('Meas:NoNumValue:Percentage' AS VARCHAR(100)) as measure_id
  from 
  (
    select sum(count_value) as all_count from @resultsDatabaseSchema.achilles_results where analysis_id = 1820
  ) t1
) t2
;


select  
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  statistic_value,
  measure_id
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
from #tempResults
;



SELECT 
  null as analysis_id,
   CAST('NOTIFICATION: percentage of non-numerical measurement records exceeds general population threshold ' AS VARCHAR(255)) as ACHILLES_HEEL_warning,
	28 as rule_id,
	cast(statistic_value as int) as record_count
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
FROM #tempResults t
--WHERE t.analysis_id IN (100730,100430) --umbrella version
WHERE measure_id = 'Meas:NoNumValue:Percentage' --t.analysis_id IN (100000)
--the intended threshold is 1 percent, this value is there to get pilot data from early adopters
	AND t.statistic_value >= 80
;


--clean up temp tables for rule 28
truncate table #tempResults;
drop table #tempResults;

--end of rule 28

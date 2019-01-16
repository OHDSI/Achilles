{DEFAULT @derivedDataSmPtCount = 11} 

select 
  cast(null as int) as analysis_id,
  stratum_1,
  cast(null as varchar(255)) as stratum_2,
  temp_cnt as statistic_value,
cast('Death:byYear:SafePatientCnt' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
   (select stratum_1,sum(count_value) as temp_cnt 
    from @resultsDatabaseSchema.achilles_results where analysis_id = 504
    group by stratum_1
   ) a
where temp_cnt >= @derivedDataSmPtCount;

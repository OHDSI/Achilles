{DEFAULT @derivedDataSmPtCount = 11} 

select 
  null as analysis_id,
  stratum_1,
  null as stratum_2,
  temp_cnt as statistic_value,
cast('Death:byYear:SafePatientCnt' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
   (select stratum_1,sum(count_value) as temp_cnt 
    from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 504     
    group by stratum_1
   ) a
where temp_cnt >= @derivedDataSmPtCount;

{DEFAULT @derivedDataSmPtCount = 11} 


select 
  null as analysis_id,
  decade as stratum_1,
  null as stratum_2,
  temp_cnt as statistic_value,
'Death:byDecade:SafePatientCnt' as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
   (select left(stratum_1,3) as decade,sum(count_value) as temp_cnt 
    from @resultsDatabaseSchema.ACHILLES_results where analysis_id = 504     
    group by left(stratum_1,3)
   ) a
where temp_cnt >= @derivedDataSmPtCount;

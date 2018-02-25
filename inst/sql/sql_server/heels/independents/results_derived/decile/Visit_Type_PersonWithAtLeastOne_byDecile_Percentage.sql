{DEFAULT @derivedDataSmPtCount = 11} 

select 
  null as analysis_id,
  a.stratum_1,
  a.stratum_4 as stratum_2,
  cast(1.0*a.person_cnt/b.population_size as FLOAT) as statistic_value,
cast('Visit:Type:PersonWithAtLeastOne:byDecile:Percentage' as varchar(255)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(select 
  stratum_1,  
  stratum_4, 
  sum(count_value) as person_cnt  
  from @resultsDatabaseSchema.ACHILLES_results 
  where analysis_id = 204 
  group by stratum_1, stratum_4) a
inner join 
(select
  stratum_4, 
  sum(count_value) as population_size
  from @resultsDatabaseSchema.ACHILLES_results 
  where analysis_id = 204 
  group by stratum_4) b
on a.stratum_4=b.stratum_4
where a.person_cnt >= @derivedDataSmPtCount;

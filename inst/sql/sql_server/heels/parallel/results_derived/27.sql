--iris measures by percentage
--for this part, derived table is trying to adopt DQI terminolgy 
--and generalize analysis naming scheme (and generalize the DQ rules)

select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  CAST(100.0*count_value/statistic.total_pts AS FLOAT) as statistic_value,
  CAST(CONCAT('ach_',CAST(analysis_id as VARCHAR(10)),':Percentage') AS VARCHAR(100)) as measure_id
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from @resultsDatabaseSchema.ACHILLES_results 
cross join (SELECT TOP 1 count_value as total_pts from @resultsDatabaseSchema.ACHILLES_results r where analysis_id =1) as statistic
where analysis_id in (2000,2001,2002,2003);

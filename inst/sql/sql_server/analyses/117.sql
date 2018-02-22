-- 117	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

select distinct 
  YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date)  as obs_month
into 
  #temp_dates
from 
  @cdmDatabaseSchema.OBSERVATION_PERIOD
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 117 as analysis_id,  
	CAST(t1.obs_month AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_117
from
	@cdmDatabaseSchema.observation_period op1,
	#temp_dates t1 
where YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) <= t1.obs_month
	and YEAR(observation_period_end_date)*100 + MONTH(observation_period_end_date) >= t1.obs_month
group by t1.obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

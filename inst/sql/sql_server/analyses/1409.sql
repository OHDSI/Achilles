-- 1409	Number of persons with continuous payer plan in each year
-- Note: using temp table instead of nested query because this gives vastly improved

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

select distinct 
  YEAR(payer_plan_period_start_date) as obs_year 
INTO
  #temp_dates
from 
  @cdmDatabaseSchema.payer_plan_period
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1409 as analysis_id,  
	CAST(t1.obs_year AS VARCHAR(255)) as stratum_1, 
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1409
from
	@cdmDatabaseSchema.PERSON p1
	inner join 
    @cdmDatabaseSchema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates t1 
where year(ppp1.payer_plan_period_START_DATE) <= t1.obs_year
	and year(ppp1.payer_plan_period_END_DATE) >= t1.obs_year
group by t1.obs_year
;

truncate table #temp_dates;
drop table #temp_dates;

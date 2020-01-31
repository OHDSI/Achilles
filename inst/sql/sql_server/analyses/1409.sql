-- 1409	Number of persons with continuous payer plan in each year
-- Note: using temp table instead of nested query because this gives vastly improved



select distinct 
  YEAR(payer_plan_period_start_date) as obs_year 
INTO
  #temp_dates_1409
from 
  @cdmDatabaseSchema.payer_plan_period
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1409 as analysis_id,  
	CAST(t1.obs_year AS VARCHAR(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1409
from
	@cdmDatabaseSchema.person p1
	inner join 
    @cdmDatabaseSchema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates_1409 t1 
where year(ppp1.payer_plan_period_START_DATE) <= t1.obs_year
	and year(ppp1.payer_plan_period_END_DATE) >= t1.obs_year
group by t1.obs_year
;

truncate table #temp_dates_1409;
drop table #temp_dates_1409;

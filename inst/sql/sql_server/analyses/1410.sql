-- 1410	Number of persons with continuous payer plan in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

--HINT DISTRIBUTE_ON_KEY(obs_month)
SELECT DISTINCT 
  YEAR(payer_plan_period_start_date)*100 + MONTH(payer_plan_period_start_date) AS obs_month,
  DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_start_date), 1) as obs_month_start,
  EOMONTH(payer_plan_period_start_date) as obs_month_end
INTO
  #temp_dates_1410
FROM 
  @cdmDatabaseSchema.payer_plan_period
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 
  1410 as analysis_id, 
	CAST(obs_month AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1410
from
	@cdmDatabaseSchema.person p1
	inner join 
  @cdmDatabaseSchema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates_1410
where ppp1.payer_plan_period_START_DATE <= obs_month_start
	and ppp1.payer_plan_period_END_DATE >= obs_month_end
group by obs_month
;

TRUNCATE TABLE #temp_dates_1410;
DROP TABLE #temp_dates_1410;

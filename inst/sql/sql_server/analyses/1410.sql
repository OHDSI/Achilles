-- 1410	Number of persons with continuous payer plan in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

SELECT DISTINCT 
  YEAR(payer_plan_period_start_date)*100 + MONTH(payer_plan_period_start_date) AS obs_month,
  CAST(CONCAT(CONCAT(CAST(YEAR(payer_plan_period_start_date) AS VARCHAR(4)), RIGHT(CONCAT('0', CAST(MONTH(payer_plan_period_start_date) AS VARCHAR(2))), 2)), '01') AS DATE) AS obs_month_start,
  DATEADD(dd,-1,DATEADD(mm,1,CAST(CONCAT(CONCAT(CAST(YEAR(payer_plan_period_start_date) AS VARCHAR(4)), RIGHT(CONCAT('0', CAST(MONTH(payer_plan_period_start_date) AS VARCHAR(2))), 2)), '01') AS DATE))) AS obs_month_end
INTO
  #temp_dates
FROM 
  @cdmDatabaseSchema.payer_plan_period
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 
  1410 as analysis_id, 
	CAST(obs_month AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1410
from
	@cdmDatabaseSchema.PERSON p1
	inner join 
  @cdmDatabaseSchema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates
where ppp1.payer_plan_period_START_DATE <= obs_month_start
	and ppp1.payer_plan_period_END_DATE >= obs_month_end
group by obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

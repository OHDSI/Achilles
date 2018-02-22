-- 110	Number of persons with continuous observation in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

SELECT DISTINCT 
  YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) AS obs_month,
  CAST(CONCAT(CONCAT(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)), RIGHT(CONCAT('0', CAST(MONTH(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2))), 2)), '01') AS DATE)
  AS obs_month_start,
  DATEADD(dd,-1,DATEADD(mm,1,CAST(CONCAT(CONCAT(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)), RIGHT(CONCAT('0', CAST(MONTH(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2))), 2)), '01') AS DATE))) AS obs_month_end
INTO
  #temp_dates
FROM @cdmDatabaseSchema.observation_period
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
SELECT 
  110 AS analysis_id, 
	CAST(obs_month AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(DISTINCT person_id) AS count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_110
FROM
	@cdmDatabaseSchema.observation_period,
	#temp_Dates
WHERE 
		observation_period_start_date <= obs_month_start
	AND
		observation_period_end_date >= obs_month_end
GROUP BY 
	obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

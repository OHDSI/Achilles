-- 109	Number of persons with continuous observation in each year
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

SELECT DISTINCT 
  YEAR(observation_period_start_date) AS obs_year,
  CAST(CONCAT(CONCAT(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)), '01'), '01') AS DATE) AS obs_year_start,
  CAST(CONCAT(CONCAT(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)), '12'), '31') AS DATE) AS obs_year_end
INTO
  #temp_dates
FROM @cdmDatabaseSchema.observation_period
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
SELECT 
  109 AS analysis_id,  
	CAST(obs_year AS VARCHAR(255)) AS stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(DISTINCT person_id) AS count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_109
FROM @cdmDatabaseSchema.observation_period,
	#temp_dates
WHERE  
		observation_period_start_date <= obs_year_start
	AND 
		observation_period_end_date >= obs_year_end
GROUP BY 
	obs_year
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

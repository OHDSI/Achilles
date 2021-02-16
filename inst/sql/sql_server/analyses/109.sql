-- 109	Number of persons with continuous observation in each year
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

--HINT DISTRIBUTE_ON_KEY(obs_year)
SELECT DISTINCT 
  YEAR(observation_period_start_date) AS obs_year,
  (YEAR(observation_period_start_date)*100 + 1)*100 + 1 AS obs_year_start,
  (YEAR(observation_period_start_date)*100 + 12)*100 + 31 AS obs_year_end
INTO
  #temp_dates_109
FROM @cdmDatabaseSchema.observation_period
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	109 AS analysis_id,  
	CAST(obs_year AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2, CAST(NULL AS VARCHAR(255)) AS stratum_3, CAST(NULL AS VARCHAR(255)) AS stratum_4, CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(DISTINCT person_id) AS count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_109
FROM @cdmDatabaseSchema.observation_period
CROSS JOIN #temp_dates_109
WHERE
	(YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date))*100 + DAY(observation_period_start_date) <= obs_year_start
AND
	(YEAR(observation_period_end_date)*100 + MONTH(observation_period_end_date))*100 + DAY(observation_period_end_date) >= obs_year_end
GROUP BY 
	obs_year
;

TRUNCATE TABLE #temp_dates_109;
DROP TABLE #temp_dates_109;

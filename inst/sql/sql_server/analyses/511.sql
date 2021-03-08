-- 511	Distribution of time from death to last condition

--HINT DISTRIBUTE_ON_KEY(count_value)
SELECT 
	511 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(count_value) AS count_value,
	MIN(count_value) AS min_value,
	MAX(count_value) AS max_value,
	CAST(AVG(1.0 * count_value) AS FLOAT) AS avg_value,
	CAST(STDEV(count_value) AS FLOAT) AS stdev_value,
	MAX(CASE WHEN p1 <= 0.50 THEN count_value ELSE - 9999 END) AS median_value,
	MAX(CASE WHEN p1 <= 0.10 THEN count_value ELSE - 9999 END) AS p10_value,
	MAX(CASE WHEN p1 <= 0.25 THEN count_value ELSE - 9999 END) AS p25_value,
	MAX(CASE WHEN p1 <= 0.75 THEN count_value ELSE - 9999 END) AS p75_value,
	MAX(CASE WHEN p1 <= 0.90 THEN count_value ELSE - 9999 END) AS p90_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_511
FROM (
SELECT 
	DATEDIFF(dd, d.death_date, co.max_date) AS count_value,
	1.0 * (ROW_NUMBER() OVER (ORDER BY DATEDIFF(dd, d.death_date, co.max_date))) / (COUNT_BIG(*) OVER () + 1) AS p1
FROM 
	@cdmDatabaseSchema.death d
JOIN (
	SELECT 
		co.person_id,
		MAX(co.condition_start_date) AS max_date
	FROM 
		@cdmDatabaseSchema.condition_occurrence co
	JOIN 
		@cdmDatabaseSchema.observation_period op 
	ON 
		co.person_id = op.person_id
	AND 
		co.condition_start_date >= op.observation_period_start_date
	AND 
		co.condition_start_date <= op.observation_period_end_date	
	GROUP BY 
		co.person_id
	) co 
ON d.person_id = co.person_id
	) t1;

-- 420	Number of condition occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(co.condition_start_date) * 100 + MONTH(co.condition_start_date) AS stratum_1,
	COUNT_BIG(co.person_id) AS count_value
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
	YEAR(co.condition_start_date) * 100 + MONTH(co.condition_start_date)
)
SELECT
	420 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_420
FROM 
	rawData;

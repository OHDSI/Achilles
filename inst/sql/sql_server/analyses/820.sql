-- 820	Number of observation records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(o.observation_date) * 100 + MONTH(o.observation_date) AS stratum_1,
	COUNT_BIG(o.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.observation o
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	o.person_id = op.person_id
AND 
	o.observation_date >= op.observation_period_start_date
AND 
	o.observation_date <= op.observation_period_end_date
GROUP BY 
	YEAR(o.observation_date) * 100 + MONTH(o.observation_date)
)
SELECT
	820 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_820
FROM 
	rawData;

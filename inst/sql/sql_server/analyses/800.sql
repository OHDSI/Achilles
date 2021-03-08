-- 800	Number of persons with at least one observation occurrence, by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	800 AS analysis_id,
	CAST(o.observation_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(DISTINCT o.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_800
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
	o.observation_concept_id;

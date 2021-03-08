-- 1800	Number of persons with at least one measurement occurrence, by measurement_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	1800 AS analysis_id,
	CAST(m.measurement_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(DISTINCT m.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1800
FROM 
	@cdmDatabaseSchema.measurement m
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	m.person_id = op.person_id
AND 
	m.measurement_date >= op.observation_period_start_date
AND 
	m.measurement_date <= op.observation_period_end_date	
GROUP BY 
	m.measurement_concept_id;


-- 1823	Number of measurement records, by measurement_concept_id and operator_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	1823 AS analysis_id,
	CAST(m.measurement_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(m.operator_concept_id AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1823
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
	m.measurement_concept_id,
	m.operator_concept_id;

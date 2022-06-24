-- 1819	Number of measurement records, by concept_id, with a value (with a mapped, non-null value_as_number)


SELECT 
	1819 AS analysis_id,
	CAST(m.measurement_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(m.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1819
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
WHERE 
	m.value_as_number IS NOT NULL
OR 
	m.value_as_concept_id != 0
GROUP BY 
	m.measurement_concept_id;


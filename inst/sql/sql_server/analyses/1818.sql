-- 1818	Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id


--HINT DISTRIBUTE_ON_KEY(person_id)
SELECT 
	m.person_id,
	m.measurement_concept_id,
	m.unit_concept_id,
	CAST(CASE 
			WHEN m.value_as_number < m.range_low
				THEN 'Below Range Low'
			WHEN m.value_as_number >= m.range_low AND m.value_as_number <= m.range_high
				THEN 'Within Range'
			WHEN m.value_as_number > m.range_high
				THEN 'Above Range High'
			ELSE 'Other'
			END AS VARCHAR(255)) AS stratum_3
INTO 
	#rawData_1818
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
AND 
	m.unit_concept_id IS NOT NULL
AND 
	m.range_low IS NOT NULL
AND 
	m.range_high IS NOT NULL;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	1818 AS analysis_id,
	CAST(measurement_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(unit_concept_id AS VARCHAR(255)) AS stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1818
FROM 
	#rawData_1818
GROUP BY 
	measurement_concept_id,
	unit_concept_id,
	stratum_3;

TRUNCATE TABLE #rawData_1818;

DROP TABLE #rawData_1818;

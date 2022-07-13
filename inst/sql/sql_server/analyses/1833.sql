-- 1833	Proportion of measurement records with a valid observation period, but no value; stratified by measurement_concept_id
--
-- stratum_1:   measurement_concept_id
-- stratum_2:   Number of measurement records with no value for the given measurement_concept_id
-- stratum_3:   Proportion == stratum_2/count_value
-- count_value: Number of measurement records for the given measurement_concept_id
--

SELECT 
	1833 AS analysis_id,
	m.measurement_concept_id AS stratum_1,
	CAST(SUM(CASE WHEN m.value_as_number IS NULL 
	          AND COALESCE(m.value_as_concept_id,0) = 0 
	    THEN 1 ELSE 0 END) AS VARCHAR(255))  AS stratum_2,
	CAST(CAST(1.0*SUM(CASE WHEN m.value_as_number IS NULL AND COALESCE(m.value_as_concept_id,0) = 0 
	                  THEN 1 ELSE 0 END)/(CASE WHEN COUNT(*)=0 THEN 1 ELSE COUNT(*) END) AS FLOAT) AS VARCHAR(255)) AS stratum_3, 
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1833
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
	m.measurement_concept_id
;

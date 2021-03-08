-- 2105	Number of exposure records by device_concept_id by device_type_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	2105 AS analysis_id,
	CAST(de.device_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(de.device_type_concept_id AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(de.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2105
FROM 
	@cdmDatabaseSchema.device_exposure de
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.device_exposure_start_date >= op.observation_period_start_date
AND 
	de.device_exposure_start_date <= op.observation_period_end_date		
GROUP BY 
	de.device_concept_id,
	de.device_type_concept_id;

-- 2125	Number of device_exposure records, by device_source_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	2125 AS analysis_id,
	CAST(de.device_source_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2125
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
	de.device_source_concept_id;

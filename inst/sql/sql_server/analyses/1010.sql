-- 1010	Number of condition_era records outside a valid observation period

SELECT 
	1010 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1010
FROM 
	@cdmDatabaseSchema.condition_era ce
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	ce.person_id = op.person_id
AND 
	ce.condition_era_start_date >= op.observation_period_start_date
AND 
	ce.condition_era_start_date <= op.observation_period_end_date
WHERE 
	op.person_id IS NULL
;

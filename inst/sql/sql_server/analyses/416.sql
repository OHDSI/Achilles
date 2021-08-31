-- 416	Number of condition occurrence records, by condition_status_concept_id, condition_type_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	416 AS analysis_id,
	CAST(co.condition_status_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(co.condition_type_concept_id AS VARCHAR(255))   AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_416
FROM 
	@cdmDatabaseSchema.condition_occurrence co
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	co.person_id = op.person_id
AND 
	co.condition_start_date >= op.observation_period_start_date
AND 
	co.condition_start_date <= op.observation_period_end_date
GROUP BY 
	co.condition_status_concept_id, co.condition_type_concept_id;

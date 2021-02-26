-- 500	Number of persons with death, by cause_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	500 AS analysis_id,
	CAST(d.cause_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(DISTINCT d.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_500
FROM 
	@cdmDatabaseSchema.death d
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	d.person_id = op.person_id
AND 
	d.death_date >= op.observation_period_start_date
AND 
	d.death_date <= op.observation_period_end_date	
GROUP BY 
	d.cause_concept_id;

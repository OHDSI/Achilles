
-- 822	Number of observation records, by observation_concept_id and value_as_concept_id, observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	822 AS analysis_id,
	CAST(o.observation_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(o.value_as_concept_id AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_822
FROM 
	@cdmDatabaseSchema.observation o
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	o.person_id = op.person_id
AND 
	o.observation_date >= op.observation_period_start_date
AND 
	o.observation_date <= op.observation_period_end_date
GROUP BY 
	o.observation_concept_id,
	o.value_as_concept_id;

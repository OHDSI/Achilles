-- 826	Number of observation records, by value_as_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	826 AS analysis_id,
	CAST(o.value_as_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_826
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
	o.value_as_concept_id;

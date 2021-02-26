
-- 823	Number of observation records, by observation_concept_id and qualifier_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	823 AS analysis_id,
	CAST(o.observation_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(o.qualifier_concept_id AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_823
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
	o.qualifier_concept_id;

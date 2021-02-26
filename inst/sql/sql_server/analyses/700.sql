-- 700	Number of persons with at least one drug occurrence, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	700 AS analysis_id,
	CAST(de.drug_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(DISTINCT de.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_700
FROM 
	@cdmDatabaseSchema.drug_exposure de
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.drug_exposure_start_date >= op.observation_period_start_date
AND 
	de.drug_exposure_start_date <= op.observation_period_end_date
GROUP BY 
	de.drug_concept_id;

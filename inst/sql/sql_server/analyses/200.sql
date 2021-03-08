-- 200	Number of persons with at least one visit occurrence, by visit_concept_id
-- restricted to visits overlapping with observation period

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	200 AS analysis_id,
	CAST(vo.visit_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(DISTINCT vo.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_200
FROM 
	@cdmDatabaseSchema.visit_occurrence vo
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vo.person_id = op.person_id
AND 
	vo.visit_start_date >= op.observation_period_start_date
AND 
	vo.visit_start_date <= op.observation_period_end_date
GROUP BY 
	vo.visit_concept_id;

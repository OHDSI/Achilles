-- 691	Number of persons that have at least x procedures

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	691 AS analysis_id,
	CAST(po.procedure_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(po.prc_cnt AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SUM(COUNT(po.person_id)) OVER (PARTITION BY po.procedure_concept_id ORDER BY po.prc_cnt DESC) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_691
FROM (
	SELECT 
		po.procedure_concept_id,
		COUNT(po.procedure_occurrence_id) AS prc_cnt,
		po.person_id
	FROM 
		@cdmDatabaseSchema.procedure_occurrence po
	JOIN 
		@cdmDatabaseSchema.observation_period op 
	ON 
		po.person_id = op.person_id
	AND 
		po.procedure_date >= op.observation_period_start_date
	AND 
		po.procedure_date <= op.observation_period_end_date
	GROUP BY 
		po.person_id,
		po.procedure_concept_id
	) po
GROUP BY 
	po.procedure_concept_id,
	po.prc_cnt;

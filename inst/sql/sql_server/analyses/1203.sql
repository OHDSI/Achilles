-- 1203	Number of visits by place of service discharge type

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	1203 AS analysis_id,
	{@cdmVersion in ('5.4')} ? 
		{CAST(vo.discharged_to_concept_id AS VARCHAR(255)) AS stratum_1,}
		:
		{CAST(vo.discharge_to_concept_id AS VARCHAR(255)) AS stratum_1,}
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1203
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
WHERE 
	{@cdmVersion in ('5.4')} ? 
		{vo.discharged_to_concept_id != 0}
		:
		{vo.discharge_to_concept_id != 0}
GROUP BY 
	{@cdmVersion in ('5.4')} ? 
		{vo.discharged_to_concept_id;}
		:
		{vo.discharge_to_concept_id;}


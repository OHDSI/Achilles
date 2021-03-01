--1308	Number of visit detail records outside valid observation period

SELECT 
	1308 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(vd.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1308
FROM 
	@cdmDatabaseSchema.visit_detail vd
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op
ON 
	op.person_id = vd.person_id
AND 
	vd.visit_detail_start_date >= op.observation_period_start_date
AND 
	vd.visit_detail_start_date <= op.observation_period_end_date
WHERE 
	op.person_id IS NULL;

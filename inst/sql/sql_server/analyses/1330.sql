-- 1330	Number of visit_detail records inside a valid observation period

SELECT 
	1330 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1330
FROM 
	@cdmDatabaseSchema.visit_detail vd
JOIN 
	@cdmDatabaseSchema.observation_period op
ON 
	op.person_id = vd.person_id
AND 
	vd.visit_detail_start_date >= op.observation_period_start_date
AND 
	vd.visit_detail_start_date <= op.observation_period_end_date
;

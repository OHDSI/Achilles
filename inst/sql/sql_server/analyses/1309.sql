-- 1309	Number of visit detail records with invalid care_site_id

SELECT 
	1309 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(vd.person_id) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1309
FROM 
	@cdmDatabaseSchema.visit_detail vd
LEFT JOIN 
	@cdmDatabaseSchema.care_site cs 
ON 
	vd.care_site_id = cs.care_site_id
WHERE 
	vd.care_site_id IS NOT NULL 
AND 
	cs.care_site_id IS NULL;

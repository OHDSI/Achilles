-- 1325	Number of visit_detail records, by visit_detail_source_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	1325 AS analysis_id,
	CAST(visit_detail_source_concept_id AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	COUNT_BIG(*) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1325
FROM 
	@cdmDatabaseSchema.visit_detail
GROUP BY 
	visit_detail_source_concept_id;

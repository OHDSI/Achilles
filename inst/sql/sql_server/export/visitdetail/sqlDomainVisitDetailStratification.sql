SELECT 
	ar.stratum_1 concept_id,
	c.concept_name,
	ar.stratum_2 cdm_table_name,
	ar.count_value record_count
FROM 
	@results_database_schema.achilles_results ar
JOIN 
	@vocab_database_schema.concept c ON c.concept_id = CAST(ar.stratum_1 AS BIGINT)
WHERE 
	ar.analysis_id = 1326

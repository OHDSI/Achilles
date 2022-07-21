SELECT 
	c1.concept_id AS concept_id,
	'Length of stay' AS category,
	ard1.min_value AS min_value,
	ard1.p10_value AS p10_value,
	ard1.p25_value AS p25_value,
	ard1.median_value AS median_value,
	ard1.p75_value AS p75_value,
	ard1.p90_value AS p90_value,
	ard1.max_value AS max_value
FROM (
	SELECT 
		CAST(stratum_1 AS BIGINT) stratum_1,
		min_value,
		p10_value,
		p25_value,
		median_value,
		p75_value,
		p90_value,
		max_value
	FROM 
		@results_database_schema.achilles_results_dist
	WHERE 
		analysis_id = 1313
	GROUP BY 
		analysis_id,
		stratum_1,
		min_value,
		p10_value,
		p25_value,
		median_value,
		p75_value,
		p90_value,
		max_value
	) ard1
JOIN 
	@vocab_database_schema.concept c1 ON ard1.stratum_1 = c1.concept_id

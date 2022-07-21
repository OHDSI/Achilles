SELECT 
	c1.concept_id AS concept_id,
	c2.concept_name AS category,
	ard.min_value AS min_value,
	ard.p10_value AS p10_value,
	ard.p25_value AS p25_value,
	ard.median_value AS median_value,
	ard.p75_value AS p75_value,
	ard.p90_value AS p90_value,
	ard.max_value AS max_value
FROM (
	SELECT 
		CAST(stratum_1 AS BIGINT) stratum_1,
		CAST(stratum_2 AS BIGINT) stratum_2,
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
		analysis_id = 1306
	GROUP BY 
		analysis_id,
		stratum_1,
		stratum_2,
		min_value,
		p10_value,
		p25_value,
		median_value,
		p75_value,
		p90_value,
		max_value
	) ard
JOIN 
	@vocab_database_schema.concept c1 ON ard.stratum_1 = c1.concept_id
JOIN 
	@vocab_database_schema.concept c2 ON ard.stratum_2 = c2.concept_id

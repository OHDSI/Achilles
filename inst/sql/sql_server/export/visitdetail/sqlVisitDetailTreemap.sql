SELECT 
	c1.concept_id,
	c1.concept_name AS concept_path,
	ar1.count_value AS num_persons,
	1.0 * ar1.count_value / denom.count_value AS percent_persons,
	1.0 * ar2.count_value / ar1.count_value AS records_per_person
FROM (
	SELECT 
		CAST(stratum_1 AS BIGINT) stratum_1,
		count_value
	FROM 
		@results_database_schema.achilles_results
	WHERE 
		analysis_id = 1300
	GROUP BY 
		analysis_id,
		stratum_1,
		count_value
	) ar1
JOIN (
	SELECT 
		CAST(stratum_1 AS BIGINT) stratum_1,
		count_value
	FROM 
		@results_database_schema.achilles_results
	WHERE 
		analysis_id = 1301
	GROUP BY 
		analysis_id,
		stratum_1,
		count_value
	) ar2 ON ar1.stratum_1 = ar2.stratum_1
JOIN 
	@vocab_database_schema.concept c1 ON ar1.stratum_1 = c1.concept_id,
	(
		SELECT count_value
		FROM @results_database_schema.achilles_results
		WHERE analysis_id = 1
	) denom

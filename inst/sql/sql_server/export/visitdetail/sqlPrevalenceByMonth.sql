SELECT 
	c1.concept_id AS concept_id, --all rows for all concepts, but you may split by conceptid
	c1.concept_name AS concept_name,
	num.stratum_2 AS x_calendar_month, -- calendar year, note, there could be blanks
	1000 * (1.0 * num.count_value / denom.count_value) AS y_prevalence_1000pp --prevalence, per 1000 persons
FROM (
	SELECT 
		CAST(stratum_1 AS BIGINT) stratum_1,
		CAST(stratum_2 AS BIGINT) stratum_2,
		count_value
	FROM 
		@results_database_schema.achilles_results
	WHERE 
		analysis_id = 1302
	GROUP BY 
		analysis_id,
		stratum_1,
		stratum_2,
		count_value
	) num
JOIN (
	SELECT 
		CAST(stratum_1 AS BIGINT) stratum_1,
		count_value
	FROM 
		@results_database_schema.achilles_results
	WHERE 
		analysis_id = 117
	GROUP BY 
		analysis_id,
		stratum_1,
		count_value
	) denom ON num.stratum_2 = denom.stratum_1 --calendar year
JOIN 
	@vocab_database_schema.concept c1 ON num.stratum_1 = c1.concept_id

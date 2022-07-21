SELECT 
	c1.concept_id AS concept_id,
	c1.concept_name AS concept_name,
	CONCAT (
		CAST(num_stratum_4 * 10 AS VARCHAR),
		'-',
		CAST((num_stratum_4 + 1) * 10 - 1 AS VARCHAR)
		) AS trellis_name, --age decile
	c2.concept_name AS series_name, --gender
	num_stratum_2 AS x_calendar_year, -- calendar year, note, there could be blanks
	ROUND(1000 * (1.0 * num_count_value / denom_count_value), 5) AS y_prevalence_1000pp --prevalence, per 1000 persons
FROM (
	SELECT 
		num.stratum_1 AS num_stratum_1,
		num.stratum_2 AS num_stratum_2,
		num.stratum_3 AS num_stratum_3,
		num.stratum_4 AS num_stratum_4,
		num.count_value AS num_count_value,
		denom.count_value AS denom_count_value
	FROM (
		SELECT 
			CAST(stratum_1 AS BIGINT) stratum_1,
			CAST(stratum_2 AS BIGINT) stratum_2,
			CAST(stratum_3 AS BIGINT) stratum_3,
			CAST(stratum_4 AS BIGINT) stratum_4,
			count_value
		FROM 
			@results_database_schema.achilles_results
		WHERE 
			analysis_id = 1304
		AND stratum_3 IN ('8507','8532')
		GROUP BY 
			stratum_1,
			stratum_2,
			stratum_3,
			stratum_4,
			count_value
		) num
	JOIN (
		SELECT 
			CAST(stratum_1 AS BIGINT) stratum_1,
			CAST(stratum_2 AS BIGINT) stratum_2,
			CAST(stratum_3 AS BIGINT) stratum_3,
			CAST(stratum_4 AS BIGINT) stratum_4,
			count_value
		FROM 
			@results_database_schema.achilles_results
		WHERE 
			analysis_id = 116
			AND stratum_2 IN ('8507','8532')
		GROUP BY 
			stratum_1,
			stratum_2,
			stratum_3,
			stratum_4,
			count_value
		) denom ON num.stratum_2 = denom.stratum_1
				AND num.stratum_3 = denom.stratum_2
				AND num.stratum_4 = denom.stratum_3
	) tmp
JOIN 
	@vocab_database_schema.concept c1 ON num_stratum_1 = c1.concept_id
JOIN 
	@vocab_database_schema.concept c2 ON num_stratum_3 = c2.concept_id
ORDER BY 
	c1.concept_id,
	num_stratum_2

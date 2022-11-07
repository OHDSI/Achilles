SELECT c1.concept_id AS CONCEPT_ID,
	c1.concept_name AS CONCEPT_NAME,
	CAST(ROUND((100.0 * tmp.num_count_value / tmp.denom_count_value), 0) AS BIGINT) AS Y_NUM_PERSONS,
	tmp.stratum_2 AS X_COUNT
FROM (
	SELECT * 
	FROM (
		SELECT count_value AS denom_count_value
		FROM @results_database_schema.achilles_results
		WHERE analysis_id = 1
		) denom,
		(
			SELECT CAST(stratum_1 AS BIGINT) stratum_1,
				CAST(stratum_2 AS BIGINT) stratum_2,
				count_value AS num_count_value
			FROM @results_database_schema.achilles_results
			WHERE analysis_id = 791
			) num
	) tmp
INNER JOIN @vocab_database_schema.concept c1 ON tmp.stratum_1 = c1.concept_id
ORDER BY tmp.stratum_2

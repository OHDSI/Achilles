select c2.concept_name as category,
	ard1.min_value as min_value,
	ard1.p10_value as P10_value,
	ard1.p25_value as P25_value,
	ard1.median_value as median_value,
	ard1.p75_value as P75_value,
	ard1.p90_value as P90_value,
	ard1.max_value as max_value
  from (
    select cast(stratum_1 as int) stratum_1, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value
    FROM @results_database_schema.ACHILLES_results_dist  
    where analysis_id = 506
    GROUP BY analysis_id, stratum_1, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value 
  ) ard1
	inner join
	@vocab_database_schema.concept c2 on ard1.stratum_1 = c2.concept_id

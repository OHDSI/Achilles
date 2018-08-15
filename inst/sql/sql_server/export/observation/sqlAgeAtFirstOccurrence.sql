select c1.concept_id as CONCEPT_ID,
	c2.concept_name as CATEGORY,
	ard1.min_value as MIN_VALUE,
	ard1.p10_value as P10_VALUE,
	ard1.p25_value as P25_VALUE,
	ard1.median_value as MEDIAN_VALUE,
	ard1.p75_value as P75_VALUE,
	ard1.p90_value as P90_VALUE,
	ard1.max_value as MAX_VALUE
from (
  select cast(stratum_1 as int) stratum_1, cast(stratum_2 as int) stratum_2, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value
  FROM @results_database_schema.ACHILLES_results_dist  
  where analysis_id = 806
  GROUP BY analysis_id, stratum_1, stratum_2, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value 
) ard1
inner join @vocab_database_schema.concept c1 on ard1.stratum_1 = c1.concept_id
inner join @vocab_database_schema.concept c2 on ard1.stratum_2 = c2.concept_id

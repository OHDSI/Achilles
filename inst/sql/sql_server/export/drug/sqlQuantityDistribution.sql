select c1.concept_id as drug_concept_id,
	'Quantity' as category,
	ard1.min_value as min_value,
	ard1.p10_value as p10_value,
	ard1.p25_value as p25_value,
	ard1.median_value as median_value,
	ard1.p75_value as p75_value,
	ard1.p90_value as p90_value,
	ard1.max_value as max_value
from (
  select cast(stratum_1 as int) stratum_1, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value
  FROM @results_database_schema.ACHILLES_results_dist  
  where analysis_id = 717 and count_value > 0
  GROUP BY analysis_id, stratum_1, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value 
) ard1
inner join @vocab_database_schema.concept c1 on ard1.stratum_1 = c1.concept_id

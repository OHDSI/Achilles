select c2.concept_id as concept_id,
	c2.concept_name as concept_name, 
	ar1.count_value as count_value
from (
  select cast(stratum_1 as int) stratum_1, count_value
  from @results_database_schema.ACHILLES_results
  where analysis_id = 505
  GROUP BY analysis_id, stratum_1, count_value
)  ar1
inner join  @vocab_database_schema.concept c2 on ar1.stratum_1 = c2.concept_id

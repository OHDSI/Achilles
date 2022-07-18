select c1.concept_id as concept_id, 
  	c1.concept_name as concept_name, 
  	ar1.stratum_2 as age,
	  ar1.count_value as count_value
from (
  select cast(stratum_1 as bigint) stratum_1,
	cast(stratum_2 as bigint) stratum_2, 
	count_value
  from @results_database_schema.achilles_results
  where analysis_id = 102
) ar1
inner join @vocab_database_schema.concept c1 on ar1.stratum_1 = c1.concept_id

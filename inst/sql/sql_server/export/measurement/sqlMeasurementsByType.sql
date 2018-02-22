select c1.concept_id as MEASUREMENT_CONCEPT_ID, 
  c1.concept_name as MEASUREMENT_CONCEPT_NAME, 
	c2.concept_id as CONCEPT_ID,
	c2.concept_name as CONCEPT_NAME, 
	ar1.count_value as COUNT_VALUE
from (
  select cast(stratum_1 as int) stratum_1, cast(stratum_2 as int) stratum_2, count_value
  FROM @results_database_schema.ACHILLES_results  
  where analysis_id = 1805
  GROUP BY analysis_id, stratum_1, stratum_2, count_value 
) ar1
inner join @vocab_database_schema.concept c1 on ar1.stratum_1 = c1.concept_id
inner join @vocab_database_schema.concept c2 on ar1.stratum_2 = c2.concept_id

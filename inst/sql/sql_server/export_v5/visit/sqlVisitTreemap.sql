select 	c1.concept_id,
	c1.concept_name as concept_path, 
	ar1.count_value as num_persons, 
	1.0*ar1.count_value / denom.count_value as percent_persons,
	1.0*ar2.count_value / ar1.count_value as records_per_person
from (select cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 200 GROUP BY analysis_id, stratum_1, count_value) ar1
	inner join
	(select cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 201 GROUP BY analysis_id, stratum_1, count_value) ar2 on ar1.stratum_1 = ar2.stratum_1
	inner join @vocab_database_schema.concept c1 on ar1.stratum_1 = c1.concept_id,
	(select count_value from @results_database_schema.ACHILLES_results where analysis_id = 1) denom


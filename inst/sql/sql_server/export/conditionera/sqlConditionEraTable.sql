select concept.concept_id,
	concept.concept_name,
  	ar1.count_value as num_persons, 
	round(1.0*ar1.count_value / denom.count_value,5) as percent_persons,
	round(1.0*ar2.count_value / ar1.count_value,5) as records_per_person,
	era.p25_value, era.median_value, era.p75_value
from 
	(select cast(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 1000 GROUP BY analysis_id, stratum_1, count_value) ar1
	join
	(select cast(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 1001 GROUP BY analysis_id, stratum_1, count_value) ar2
	on ar1.stratum_1 = ar2.stratum_1
	join
	(select concept_id, concept_name from @vocab_database_schema.concept) concept 
	on concept.concept_id = ar1.stratum_1
	join 
	(select cast(stratum_1 as bigint) concept_id, min_value, p10_value, p25_value, median_value, p75_value, p90_value, max_value FROM @results_database_schema.achilles_results_dist where analysis_id = 1007) era
	on era.concept_id = ar1.stratum_1,
	(select count_value from @results_database_schema.achilles_results where analysis_id = 1) denom
order by ar1.count_value desc

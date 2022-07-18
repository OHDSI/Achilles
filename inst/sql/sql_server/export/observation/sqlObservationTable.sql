select concept.concept_id,
	concept.concept_name,
  	ar1.count_value as num_persons, 
	round(1.0*ar1.count_value / denom.count_value,5) as percent_persons,
	round(1.0*ar2.count_value / ar1.count_value,5) as records_per_person
from 
	(select cast(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 800 GROUP BY analysis_id, stratum_1, count_value) ar1
	inner join
	(select cast(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 801 GROUP BY analysis_id, stratum_1, count_value) ar2
	on ar1.stratum_1 = ar2.stratum_1
	inner join
	(
		select concept_id, concept_name
		from @vocab_database_schema.concept
		where domain_id = 'Observation'
	) concept
	on concept.concept_id = ar1.stratum_1 and concept.concept_id = ar2.stratum_1,
	(select count_value from @results_database_schema.achilles_results where analysis_id = 1) denom
order by ar1.count_value desc

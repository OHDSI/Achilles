select stratum_2 concept_id, concept_name, sum(count_value) record_count 
from @results_database_schema.achilles_results ar
join @vocab_database_schema.concept c on c.concept_id = cast(ar.stratum_2 as bigint)
where analysis_id = 705
group by stratum_2,concept_name;

select stratum_1 concept_id, concept_name, stratum_2 cdm_table_name, count_value record_count 
from @results_database_schema.achilles_results ar
join @vocab_database_schema.concept c on c.concept_id = cast(ar.stratum_1 as bigint)
where analysis_id = 226

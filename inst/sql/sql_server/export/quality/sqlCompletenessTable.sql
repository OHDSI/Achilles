select stratum_1 cdm_table_name, stratum_2 cdm_field_name, stratum_3 source_value, count_value record_count
from @results_database_schema.achilles_results 
where analysis_id = 1900;

select stratum_1 DOMAIN_BITS,stratum_2 PERCENT_VALUE, count_value COUNT_VALUE 
from @results_database_schema.achilles_results 
where analysis_id = 2004;

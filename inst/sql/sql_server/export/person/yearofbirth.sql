select cast(ar.stratum_1 as bigint) as year, count_value as count_person
from @results_database_schema.achilles_results ar
where ar.analysis_id = 3

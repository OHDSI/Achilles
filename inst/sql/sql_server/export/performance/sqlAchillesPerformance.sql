select aa.analysis_id, aa.analysis_name, aa.category, stratum_1 elapsed_seconds
from @results_database_schema.ACHILLES_ANALYSIS aa
join @results_database_schema.ACHILLES_RESULTS ar on aa.analysis_id + 2000000 = ar.analysis_id
union
select aa.analysis_id, aa.analysis_name, aa.category, stratum_1 elapsed_seconds
from @results_database_schema.ACHILLES_ANALYSIS aa
join @results_database_schema.ACHILLES_RESULTS_DIST ar on aa.analysis_id + 2000000 = ar.analysis_id

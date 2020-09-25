select aa.analysis_id AnalysisId, aa.analysis_name AnalysisName, stratum_1 ElapsedSeconds
from @results_database_schema.ACHILLES_ANALYSIS aa
join @results_database_schema.ACHILLES_RESULTS ar on aa.analysis_id + 2000000 = ar.analysis_id
union
select aa.analysis_id AnalysisId, aa.analysis_name AnalysisName, stratum_1 ElapsedSeconds
from @results_database_schema.ACHILLES_ANALYSIS aa
join @results_database_schema.ACHILLES_RESULTS_DIST ar on aa.analysis_id + 2000000 = ar.analysis_id

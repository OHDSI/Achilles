select min(cast(ar1.stratum_1 as bigint)) as min_value,
  max(cast(ar1.stratum_1 as bigint)) as max_value,
	1 as interval_size
from @results_database_schema.achilles_results ar1
where ar1.analysis_id = 3

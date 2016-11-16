select ar1.stratum_1 as month_year, 
  ar1.count_value as count_value, 
	round(1.0*ar1.count_value / denom.count_value,5) as percent_value
from (select cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 110 GROUP BY analysis_id, stratum_1, count_value) ar1,
	(select count_value from @results_database_schema.ACHILLES_results where analysis_id = 1) denom

  
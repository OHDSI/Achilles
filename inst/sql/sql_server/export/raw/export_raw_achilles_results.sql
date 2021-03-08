SELECT 
  analysis_id,
  stratum_1,
  stratum_2,
  stratum_3,
  stratum_4,
  stratum_5,
  count_value
FROM @results_database_schema.achilles_results
WHERE count_value > @min_cell_count
{@analysis_ids != ''} ? {AND analysis_id IN (@analysis_ids)}
;

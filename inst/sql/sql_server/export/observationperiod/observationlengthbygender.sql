select c1.concept_name as Category,
  ard1.min_value as MinValue,
  ard1.p10_value as P10Value,
  ard1.p25_value as P25Value,
  ard1.median_value as MedianValue,
  ard1.p75_value as P75Value,
  ard1.p90_value as P90Value,
  ard1.max_value as MaxValue
from ACHILLES_results_dist ard1
inner join @cdmSchema.dbo.concept c1 on CAST(ard1.stratum_1 AS INT) = c1.concept_id
where ard1.analysis_id = 106
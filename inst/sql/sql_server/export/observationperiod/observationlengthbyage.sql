 select cast(cast(ard1.stratum_1 as int)*10 as varchar) + '-' + cast((cast(ard1.stratum_1 as int)+1)*10-1 as varchar)  as Category,
  ard1.min_value as MinValue,
  ard1.p10_value as P10Value,
  ard1.p25_value as P25Value,
  ard1.median_value as MedianValue,
  ard1.p75_value as P75Value,
  ard1.p90_value as P90Value,
  ard1.max_value as MaxValue
from ACHILLES_results_dist ard1
where ard1.analysis_id = 107
order by cast(ard1.stratum_1 as int) asc
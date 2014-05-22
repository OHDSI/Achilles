  select c1.concept_id as ConceptId,
    c2.concept_name as Category,
  	ard1.min_value as MinValue,
  	ard1.p10_value as P10Value,
  	ard1.p25_value as P25Value,
  	ard1.median_value as MedianValue,
  	ard1.p75_value as P75Value,
  	ard1.p90_value as P90Value,
  	ard1.max_value as MaxValue
  from ACHILLES_results_dist ard1
  	inner join
  	concept c1
  	on ard1.stratum_1 = c1.concept_id
  	inner join
  	concept c2
  	on ard1.stratum_2 = c2.concept_id
  where ard1.analysis_id = 406
  select c1.concept_id as ConceptId, 
    c2.concept_name as ConceptName, 
  	ar1.count_value as CountValue
  from ACHILLES_results ar1
  	inner join
  	concept c1
  	on ar1.stratum_1 = c1.concept_id
  	inner join
  	concept c2
  	on ar1.stratum_2 = c2.concept_id
  where ar1.analysis_id = 405
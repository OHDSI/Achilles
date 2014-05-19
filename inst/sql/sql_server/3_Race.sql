select c1.concept_id as ConceptId, 
  c1.concept_name as ConceptName, 
	ar1.count_value as CountValue
from ACHILLES_results ar1
	inner join
	concept c1
	on ar1.stratum_1 = c1.concept_id
where ar1.analysis_id = 4

select row_number() over (order by ar1.stratum_1) as ConceptId, 
	ar1.stratum_1 as ConceptName, 
	ar1.count_value as CountValue
from ACHILLES_results ar1
where ar1.analysis_id = 113
select c2.concept_id as concept_id,
	c2.concept_name as concept_name, 
	ar1.count_value as count_value
from ACHILLES_results ar1
	inner join  @cdm_database_schema.concept c2 on CAST(ar1.stratum_1 AS INT) = c2.concept_id
where ar1.analysis_id = 505
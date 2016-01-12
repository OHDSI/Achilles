select c2.concept_id as concept_id,
	c2.concept_name as concept_name, 
	ar1.count_value as count_value
from @cdm_database_schema.ACHILLES_results ar1
	inner join  @cdm_database_schema.concept c2 on ar1.stratum_1 = CAST(c2.concept_id as VARCHAR)
where ar1.analysis_id = 505
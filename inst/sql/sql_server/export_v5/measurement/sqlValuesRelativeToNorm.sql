select c1.concept_id as MEASUREMENT_CONCEPT_ID, 
	c1.concept_name as MEASUREMENT_CONCEPT_NAME,
	c2.concept_id as concept_id,
	c2.concept_name + ': ' + ar1.stratum_3 as concept_name, 
	ar1.count_value as count_value
from @cdm_database_schema.ACHILLES_resultss ar1
	inner join @cdm_database_schema.concept c1 on ar1.stratum_1 = CAST(c1.concept_id as VARCHAR)
	inner join @cdm_database_schema.concept c2 on ar1.stratum_2 = CAST(c2.concept_id as VARCHAR)
where ar1.analysis_id = 1818
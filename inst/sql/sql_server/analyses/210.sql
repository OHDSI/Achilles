--210	Number of visit records with invalid care_site_id


select 210 as analysis_id,
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(vo1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_210
from
	@cdmDatabaseSchema.visit_occurrence vo1
	left join @cdmDatabaseSchema.care_site cs1
	on vo1.care_site_id = cs1.care_site_id
where vo1.care_site_id is not null
	and cs1.care_site_id is null
;

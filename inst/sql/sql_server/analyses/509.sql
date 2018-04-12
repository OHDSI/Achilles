-- 509	Number of death records with invalid person_id


select 509 as analysis_id, 
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(d1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_509
from
	@cdmDatabaseSchema.death d1
		left join @cdmDatabaseSchema.person p1
		on d1.person_id = p1.person_id
where p1.person_id is null
;

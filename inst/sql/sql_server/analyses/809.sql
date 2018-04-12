-- 809	Number of observation records with invalid person_id


select 809 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(o1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_809
from
	@cdmDatabaseSchema.observation o1
	left join @cdmDatabaseSchema.PERSON p1
	on p1.person_id = o1.person_id
where p1.person_id is null
;

-- 409	Number of condition occurrence records with invalid person_id


select 409 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(co1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_409
from
	@cdmDatabaseSchema.condition_occurrence co1
	left join @cdmDatabaseSchema.PERSON p1
	on p1.person_id = co1.person_id
where p1.person_id is null
;

-- 609	Number of procedure occurrence records with invalid person_id


select 609 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(po1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_609
from
	@cdmDatabaseSchema.procedure_occurrence po1
	left join @cdmDatabaseSchema.PERSON p1
	on p1.person_id = po1.person_id
where p1.person_id is null
;

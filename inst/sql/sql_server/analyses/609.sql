-- 609	Number of procedure occurrence records with invalid person_id


select 609 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(po1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_609
from
	@cdmDatabaseSchema.procedure_occurrence po1
	left join @cdmDatabaseSchema.person p1
	on p1.person_id = po1.person_id
where p1.person_id is null
;

-- 509	Number of death records with invalid person_id


select 509 as analysis_id, 
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(d1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_509
from
	@cdmDatabaseSchema.death d1
		left join @cdmDatabaseSchema.person p1
		on d1.person_id = p1.person_id
where p1.person_id is null
;

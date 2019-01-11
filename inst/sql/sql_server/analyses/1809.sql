-- 1809	Number of measurement records with invalid person_id


select 1809 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1809
from @cdmDatabaseSchema.measurement m
	left join @cdmDatabaseSchema.person p1 on p1.person_id = m.person_id
where p1.person_id is null
;

-- 1809	Number of measurement records with invalid person_id


select 1809 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1809
from @cdmDatabaseSchema.measurement m
	left join @cdmDatabaseSchema.PERSON p1 on p1.person_id = m.person_id
where p1.person_id is null
;

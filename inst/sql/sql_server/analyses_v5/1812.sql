-- 1812	Number of measurement records with invalid provider_id


select 1812 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1812
from @cdmDatabaseSchema.measurement m
	left join @cdmDatabaseSchema.provider p on p.provider_id = m.provider_id
where m.provider_id is not null
	and p.provider_id is null
;

-- 812	Number of observation records with invalid provider_id


select 812 as analysis_id,
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,  
	COUNT_BIG(o1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_812
from
	@cdmDatabaseSchema.observation o1
	left join @cdmDatabaseSchema.provider p1
	on p1.provider_id = o1.provider_id
where o1.provider_id is not null
	and p1.provider_id is null
;

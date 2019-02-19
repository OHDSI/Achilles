-- 1008	Number of condition eras with invalid person


select 1008 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1008
from
	@cdmDatabaseSchema.condition_era ce1
	left join @cdmDatabaseSchema.person p1
	on p1.person_id = ce1.person_id
where p1.person_id is null
;

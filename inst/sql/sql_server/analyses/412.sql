-- 412	Number of condition occurrence records with invalid provider_id


select 412 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(co1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_412
from
	@cdmDatabaseSchema.condition_occurrence co1
	left join @cdmDatabaseSchema.provider p1
	on p1.provider_id = co1.provider_id
where co1.provider_id is not null
	and p1.provider_id is null
;

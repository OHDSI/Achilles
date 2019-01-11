-- 7	Number of persons with invalid provider_id

select 7 as analysis_id,  
cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_7
from @cdmDatabaseSchema.person p1
	left join @cdmDatabaseSchema.provider pr1
	on p1.provider_id = pr1.provider_id
where p1.provider_id is not null
	and pr1.provider_id is null
;

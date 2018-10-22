-- 302	Number of providers with invalid care site id


select 302 as analysis_id,
cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(provider_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_302
from @cdmDatabaseSchema.provider p1
	left join @cdmDatabaseSchema.care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.care_site_id is null
;

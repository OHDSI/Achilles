-- 8	Number of persons with invalid location_id

select 8 as analysis_id,  
cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_8
from @cdmDatabaseSchema.person p1
	left join @cdmDatabaseSchema.location l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.location_id is null
;

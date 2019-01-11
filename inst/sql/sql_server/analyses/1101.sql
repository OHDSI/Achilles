-- 1101	Number of persons by location state

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1101 as analysis_id,  
	CAST(l1.state AS VARCHAR(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1101
from @cdmDatabaseSchema.person p1
	inner join @cdmDatabaseSchema.location l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.state is not null
group by l1.state;

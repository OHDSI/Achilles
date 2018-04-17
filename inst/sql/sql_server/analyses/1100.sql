-- 1100	Number of persons by location 3-digit zip

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1100 as analysis_id,  
	CAST(left(l1.zip,3) AS VARCHAR(255)) as stratum_1, 
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1100
from @cdmDatabaseSchema.PERSON p1
	inner join @cdmDatabaseSchema.LOCATION l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.zip is not null
group by left(l1.zip,3);

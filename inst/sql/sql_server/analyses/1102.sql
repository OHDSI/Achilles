-- 1102	Number of care sites by location 3-digit zip

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1102 as analysis_id,  
	CAST(left(l1.zip,3) AS VARCHAR(255)) as stratum_1, 
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct care_site_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1102
from @cdmDatabaseSchema.care_site cs1
	inner join @cdmDatabaseSchema.LOCATION l1
	on cs1.location_id = l1.location_id
where cs1.location_id is not null
	and l1.zip is not null
group by left(l1.zip,3);

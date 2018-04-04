-- 8	Number of persons with invalid location_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 8 as analysis_id,  
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_8
from @cdmDatabaseSchema.PERSON p1
	left join @cdmDatabaseSchema.location l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.location_id is null
;

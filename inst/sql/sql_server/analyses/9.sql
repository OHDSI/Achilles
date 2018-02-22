-- 9	Number of persons with invalid care_site_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 9 as analysis_id,  
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_9
from @cdmDatabaseSchema.PERSON p1
	left join @cdmDatabaseSchema.care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.care_site_id is null
;

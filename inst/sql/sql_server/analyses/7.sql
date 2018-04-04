-- 7	Number of persons with invalid provider_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 7 as analysis_id,  
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_7
from @cdmDatabaseSchema.PERSON p1
	left join @cdmDatabaseSchema.provider pr1
	on p1.provider_id = pr1.provider_id
where p1.provider_id is not null
	and pr1.provider_id is null
;

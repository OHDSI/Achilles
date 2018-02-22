-- 1008	Number of condition eras with invalid person

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1008 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1008
from
	@cdmDatabaseSchema.condition_era ce1
	left join @cdmDatabaseSchema.PERSON p1
	on p1.person_id = ce1.person_id
where p1.person_id is null
;

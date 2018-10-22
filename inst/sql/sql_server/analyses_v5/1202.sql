-- 1202	Number of care sites by place of service

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1202 as analysis_id,  
	CAST(cs1.place_of_service_concept_id AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(care_site_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1202
from @cdmDatabaseSchema.care_site cs1
where cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;

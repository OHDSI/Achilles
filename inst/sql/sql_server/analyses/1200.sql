-- 1200	Number of persons by place of service

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1200 as analysis_id,  
	CAST(cs1.place_of_service_concept_id AS VARCHAR(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1200
from @cdmDatabaseSchema.person p1
	inner join @cdmDatabaseSchema.care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;

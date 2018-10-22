-- 505	Number of death records, by death_type_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 505 as analysis_id, 
	CAST(death_type_concept_id AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_505
from
	@cdmDatabaseSchema.death d1
group by death_type_concept_id
;

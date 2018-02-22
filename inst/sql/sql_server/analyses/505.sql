-- 505	Number of death records, by death_type_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 505 as analysis_id, 
	CAST(death_type_concept_id AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_505
from
	@cdmDatabaseSchema.death d1
group by death_type_concept_id
;

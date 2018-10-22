-- 1001	Number of condition occurrence records, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1001 as analysis_id, 
	CAST(ce1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1001
from
	@cdmDatabaseSchema.condition_era ce1
group by ce1.condition_CONCEPT_ID
;

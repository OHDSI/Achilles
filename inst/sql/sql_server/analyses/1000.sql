-- 1000	Number of persons with at least one condition occurrence, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1000 as analysis_id, 
	CAST(ce1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1000
from
	@cdmDatabaseSchema.condition_era ce1
group by ce1.condition_CONCEPT_ID
;

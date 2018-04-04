-- 800	Number of persons with at least one observation occurrence, by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 800 as analysis_id, 
	CAST(o1.observation_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct o1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_800
from
	@cdmDatabaseSchema.observation o1
group by o1.observation_CONCEPT_ID
;

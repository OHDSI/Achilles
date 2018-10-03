-- 801	Number of observation occurrence records, by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 801 as analysis_id, 
	CAST(o1.observation_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(o1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_801
from
	@cdmDatabaseSchema.observation o1
group by o1.observation_CONCEPT_ID
;

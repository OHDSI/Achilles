-- 802	Number of persons by observation occurrence start month, by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 802 as analysis_id,   
	CAST(o1.observation_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(observation_datetime)*100 + month(observation_datetime) AS VARCHAR(255)) as stratum_2,
	cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_802
from
@cdmDatabaseSchema.observation o1
group by o1.observation_concept_id, 
	YEAR(observation_datetime)*100 + month(observation_datetime)
;

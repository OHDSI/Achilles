
-- 822	Number of observation records, by observation_concept_id and value_as_concept_id, observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select
	822 AS analysis_id,
	cast(observation_concept_id AS varchar(255)) AS stratum_1, 
	cast(value_as_concept_id AS varchar(255)) AS stratum_2,
	cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, 
	cast(null as varchar(255)) as stratum_5,
	count_big(*) AS count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_822
from @cdmDatabaseSchema.observation
group by observation_concept_id, value_as_concept_id;
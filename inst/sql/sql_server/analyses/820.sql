-- 820	Number of observation records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 820 as analysis_id,   
	CAST(YEAR(observation_date)*100 + month(observation_date) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_820
from
@cdmDatabaseSchema.observation o1
group by YEAR(observation_date)*100 + month(observation_date)
;

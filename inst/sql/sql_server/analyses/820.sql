-- 820	Number of observation records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 820 as analysis_id,   
	CAST(YEAR(observation_date)*100 + month(observation_date) AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_820
from
@cdmDatabaseSchema.observation o1
group by YEAR(observation_date)*100 + month(observation_date)
;

-- 112	Number of persons by observation period end month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 112 as analysis_id,  
	CAST(YEAR(observation_period_end_date)*100 + month(observation_period_end_date) AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_112
from
	@cdmDatabaseSchema.observation_period op1
group by YEAR(observation_period_end_date)*100 + month(observation_period_end_date)
;

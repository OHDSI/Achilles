-- 101	Number of persons by age, with age at first observation period

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 101 as analysis_id,   CAST(year(op1.index_date) - p1.YEAR_OF_BIRTH AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_101
from @cdmDatabaseSchema.PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from @cdmDatabaseSchema.OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by year(op1.index_date) - p1.YEAR_OF_BIRTH;

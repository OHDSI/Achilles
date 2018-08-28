-- 108	Number of persons by length of observation period, in 30d increments

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 108 as analysis_id,  CAST(floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30) AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct p1.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_108
from @cdmDatabaseSchema.PERSON p1
	inner join 
	(select person_id, 
		OBSERVATION_PERIOD_START_DATE, 
		OBSERVATION_PERIOD_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
		 from @cdmDatabaseSchema.OBSERVATION_PERIOD
	) op1
	on p1.PERSON_ID = op1.PERSON_ID
	where op1.rn1 = 1
group by floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30)
;

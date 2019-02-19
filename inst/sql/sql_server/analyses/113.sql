-- 113	Number of persons by number of observation periods

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 113 as analysis_id,  
	CAST(op1.num_periods AS VARCHAR(255)) as stratum_1, 
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_113
from
	(select person_id, COUNT_BIG(OBSERVATION_period_start_date) as num_periods from @cdmDatabaseSchema.observation_period group by PERSON_ID) op1
group by op1.num_periods
;

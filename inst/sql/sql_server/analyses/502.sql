-- 502	Number of persons by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 502 as analysis_id,   
	CAST(YEAR(death_date)*100 + month(death_date) AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_502
from
@cdmDatabaseSchema.death d1
group by YEAR(death_date)*100 + month(death_date)
;

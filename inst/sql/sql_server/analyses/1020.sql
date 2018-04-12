-- 1020	Number of drug era records by drug era start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1020 as analysis_id,   
	CAST(YEAR(condition_era_start_date)*100 + month(condition_era_start_date) AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1020
from
@cdmDatabaseSchema.condition_era ce1
group by YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
;

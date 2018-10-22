-- 420	Number of condition occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 420 as analysis_id,   
	CAST(YEAR(condition_start_datetime)*100 + month(condition_start_datetime) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_420
from
@cdmDatabaseSchema.condition_occurrence co1
group by YEAR(condition_start_datetime)*100 + month(condition_start_datetime)
;

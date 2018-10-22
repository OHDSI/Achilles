-- 620	Number of procedure occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 620 as analysis_id,   
	CAST(YEAR(procedure_datetime)*100 + month(procedure_datetime) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_620
from
@cdmDatabaseSchema.procedure_occurrence po1
group by YEAR(procedure_datetime)*100 + month(procedure_datetime)
;

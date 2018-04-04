-- 620	Number of procedure occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 620 as analysis_id,   
	CAST(YEAR(procedure_date)*100 + month(procedure_date) AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_620
from
@cdmDatabaseSchema.procedure_occurrence po1
group by YEAR(procedure_date)*100 + month(procedure_date)
;

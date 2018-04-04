-- 602	Number of persons by procedure occurrence start month, by procedure_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 602 as analysis_id,   
	CAST(po1.procedure_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(procedure_date)*100 + month(procedure_date) AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_602
from
@cdmDatabaseSchema.procedure_occurrence po1
group by po1.procedure_concept_id, 
	YEAR(procedure_date)*100 + month(procedure_date)
;

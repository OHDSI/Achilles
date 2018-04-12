-- 605	Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 605 as analysis_id, 
	CAST(po1.procedure_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(po1.procedure_type_concept_id AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(po1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_605
from
	@cdmDatabaseSchema.procedure_occurrence po1
group by po1.procedure_CONCEPT_ID,	
	po1.procedure_type_concept_id
;

-- 600	Number of persons with at least one procedure occurrence, by procedure_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 600 as analysis_id, 
	CAST(po1.procedure_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct po1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_600
from
	@cdmDatabaseSchema.procedure_occurrence po1
group by po1.procedure_CONCEPT_ID
;

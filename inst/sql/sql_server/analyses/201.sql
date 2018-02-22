-- 201	Number of visit occurrence records, by visit_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 201 as analysis_id, 
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(vo1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_201
from
	@cdmDatabaseSchema.visit_occurrence vo1
group by vo1.visit_concept_id
;

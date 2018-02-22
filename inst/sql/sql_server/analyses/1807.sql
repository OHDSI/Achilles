-- 1807	Number of measurement occurrence records, by measurement_concept_id and unit_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1807 as analysis_id, 
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(m.unit_concept_id AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1807
from @cdmDatabaseSchema.measurement m
group by m.measurement_concept_id, m.unit_concept_id
;

-- 1800	Number of persons with at least one measurement occurrence, by measurement_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1800 as analysis_id, 
	CAST(m.measurement_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1800
from
	@cdmDatabaseSchema.measurement m
group by m.measurement_CONCEPT_ID
;

-- 202	Number of persons by visit occurrence start month, by visit_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 202 as analysis_id,   
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(visit_start_date)*100 + month(visit_start_date) AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_202
from
@cdmDatabaseSchema.visit_occurrence vo1
group by vo1.visit_concept_id, 
	YEAR(visit_start_date)*100 + month(visit_start_date)
;

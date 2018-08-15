-- 204	Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 204 as analysis_id,   
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(visit_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(visit_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_204
from @cdmDatabaseSchema.PERSON p1
inner join
@cdmDatabaseSchema.visit_occurrence vo1
on p1.person_id = vo1.person_id
group by vo1.visit_concept_id, 
	YEAR(visit_start_date),
	p1.gender_concept_id,
	floor((year(visit_start_date) - p1.year_of_birth)/10)
;

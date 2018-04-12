-- 1804	Number of persons with at least one measurement occurrence, by measurement_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1804 as analysis_id,   
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(measurement_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(measurement_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1804
from @cdmDatabaseSchema.PERSON p1
inner join @cdmDatabaseSchema.measurement m on p1.person_id = m.person_id
group by m.measurement_concept_id, 
	YEAR(measurement_date),
	p1.gender_concept_id,
	floor((year(measurement_date) - p1.year_of_birth)/10)
;

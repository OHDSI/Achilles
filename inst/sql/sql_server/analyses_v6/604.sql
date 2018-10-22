-- 604	Number of persons with at least one procedure occurrence, by procedure_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 604 as analysis_id,   
	CAST(po1.procedure_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(procedure_datetime) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(procedure_datetime) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_604
from @cdmDatabaseSchema.PERSON p1
inner join
@cdmDatabaseSchema.procedure_occurrence po1
on p1.person_id = po1.person_id
group by po1.procedure_concept_id, 
	YEAR(procedure_datetime),
	p1.gender_concept_id,
	floor((year(procedure_datetime) - p1.year_of_birth)/10)
;

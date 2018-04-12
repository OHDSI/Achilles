-- 1004	Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1004 as analysis_id,   
	CAST(ce1.condition_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(condition_era_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(condition_era_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1004
from @cdmDatabaseSchema.PERSON p1
inner join
@cdmDatabaseSchema.condition_era ce1
on p1.person_id = ce1.person_id
group by ce1.condition_concept_id, 
	YEAR(condition_era_start_date),
	p1.gender_concept_id,
	floor((year(condition_era_start_date) - p1.year_of_birth)/10)
;

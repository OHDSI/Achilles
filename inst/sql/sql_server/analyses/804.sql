-- 804	Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 804 as analysis_id,   
	CAST(o1.observation_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(observation_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(observation_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_804
from @cdmDatabaseSchema.PERSON p1
inner join
@cdmDatabaseSchema.observation o1
on p1.person_id = o1.person_id
group by o1.observation_concept_id, 
	YEAR(observation_date),
	p1.gender_concept_id,
	floor((year(observation_date) - p1.year_of_birth)/10)
;

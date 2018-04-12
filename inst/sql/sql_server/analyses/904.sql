-- 904	Number of persons with at least one drug occurrence, by drug_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 904 as analysis_id,   
	CAST(de1.drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(drug_era_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(drug_era_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_904
from @cdmDatabaseSchema.PERSON p1
inner join
@cdmDatabaseSchema.drug_era de1
on p1.person_id = de1.person_id
group by de1.drug_concept_id, 
	YEAR(drug_era_start_date),
	p1.gender_concept_id,
	floor((year(drug_era_start_date) - p1.year_of_birth)/10)
;

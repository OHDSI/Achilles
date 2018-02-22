-- 2104	Number of persons with at least one device occurrence, by device_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 2104 as analysis_id,   
	CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(device_exposure_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(device_exposure_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2104
from @cdmDatabaseSchema.PERSON p1
inner join @cdmDatabaseSchema.device_exposure m on p1.person_id = m.person_id
group by m.device_CONCEPT_ID, 
	YEAR(device_exposure_start_date),
	p1.gender_concept_id,
	floor((year(device_exposure_start_date) - p1.year_of_birth)/10)
;

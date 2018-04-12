-- 2102	Number of persons by device by  start month, by device_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 2102 as analysis_id,   
	CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(device_exposure_start_date)*100 + month(device_exposure_start_date) AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2102
from
	@cdmDatabaseSchema.device_exposure m
group by m.device_CONCEPT_ID, 
	YEAR(device_exposure_start_date)*100 + month(device_exposure_start_date)
;

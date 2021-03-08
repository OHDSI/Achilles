-- 2104	Number of persons with at least one device occurrence, by device_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	de.device_concept_id AS stratum_1,
	YEAR(de.device_exposure_start_date) AS stratum_2,
	p.gender_concept_id AS stratum_3,
	FLOOR((YEAR(de.device_exposure_start_date) - p.year_of_birth) / 10) AS stratum_4,
	COUNT_BIG(DISTINCT p.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.device_exposure de 
ON 
	p.person_id = de.person_id
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.device_exposure_start_date >= op.observation_period_start_date
AND 
	de.device_exposure_start_date <= op.observation_period_end_date		
GROUP BY 
	de.device_concept_id,
	YEAR(de.device_exposure_start_date),
	p.gender_concept_id,
	FLOOR((YEAR(de.device_exposure_start_date) - p.year_of_birth) / 10)
)
SELECT
	2104 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) AS stratum_3,
	CAST(stratum_4 AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2104
FROM 
	rawData;

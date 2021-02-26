-- 1804	Number of persons with at least one measurement occurrence, by measurement_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	m.measurement_concept_id AS stratum_1,
	YEAR(m.measurement_date) AS stratum_2,
	p.gender_concept_id AS stratum_3,
	FLOOR((YEAR(m.measurement_date) - p.year_of_birth) / 10) AS stratum_4,
	COUNT_BIG(DISTINCT p.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.measurement m 
ON 
	p.person_id = m.person_id
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	m.person_id = op.person_id
AND 
	m.measurement_date >= op.observation_period_start_date
AND 
	m.measurement_date <= op.observation_period_end_date		
GROUP BY 
	m.measurement_concept_id,
	YEAR(m.measurement_date),
	p.gender_concept_id,
	FLOOR((YEAR(m.measurement_date) - p.year_of_birth) / 10)
)
SELECT
	1804 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) AS stratum_3,
	CAST(stratum_4 AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1804
FROM 
	rawData;

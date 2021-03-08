-- 204	Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	vo.visit_concept_id AS stratum_1,
	YEAR(vo.visit_start_date) AS stratum_2,
	p.gender_concept_id AS stratum_3,
	FLOOR((YEAR(vo.visit_start_date) - p.year_of_birth) / 10) AS stratum_4,
	COUNT_BIG(DISTINCT p.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.visit_occurrence vo 
ON 
	p.person_id = vo.person_id
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vo.person_id = op.person_id
AND 
	vo.visit_start_date >= op.observation_period_start_date
AND 
	vo.visit_start_date <= op.observation_period_end_date
GROUP BY 
	vo.visit_concept_id,
	YEAR(vo.visit_start_date),
	p.gender_concept_id,
	FLOOR((YEAR(vo.visit_start_date) - p.year_of_birth) / 10)
)
SELECT
	204 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 as varchar(255)) AS stratum_2,
	CAST(stratum_3 as varchar(255)) AS stratum_3,
	CAST(stratum_4 as varchar(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_204
FROM 
	rawData;

-- 1312	Number of persons with at least one visit detail by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(vd.visit_detail_start_date) AS stratum_1,
	p.gender_concept_id AS stratum_2,
	FLOOR((YEAR(vd.visit_detail_start_date) - p.year_of_birth) / 10) AS stratum_3,
	COUNT_BIG(DISTINCT vd.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.visit_detail vd 
ON 
	vd.person_id = p.person_id
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vd.person_id = op.person_id
AND	
	vd.visit_detail_start_date >= op.observation_period_start_date  
AND 
	vd.visit_detail_start_date <= op.observation_period_end_date
GROUP BY 
	YEAR(vd.visit_detail_start_date),
	p.gender_concept_id,
	FLOOR((YEAR(vd.visit_detail_start_date) - p.year_of_birth) / 10)
)
SELECT
	1312 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS varchar(255)) AS stratum_2,
	CAST(stratum_3 AS varchar(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1312
FROM 
	rawData;

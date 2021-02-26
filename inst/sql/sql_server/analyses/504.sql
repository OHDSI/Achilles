-- 504	Number of persons with a death, by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(d.death_date) AS stratum_1,
	p.gender_concept_id AS stratum_2,
	FLOOR((YEAR(d.death_date) - p.year_of_birth) / 10) AS stratum_3,
	COUNT_BIG(DISTINCT p.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.death d 
ON 
	p.person_id = d.person_id
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	d.person_id = op.person_id
AND 
	d.death_date >= op.observation_period_start_date
AND 
	d.death_date <= op.observation_period_end_date	
GROUP BY 
	YEAR(d.death_date),
	p.gender_concept_id,
	FLOOR((YEAR(d.death_date) - p.year_of_birth) / 10)
)
SELECT
	504 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_504
FROM 
	rawData;

-- 1004	Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	ce.condition_concept_id AS stratum_1,
	YEAR(ce.condition_era_start_date) AS stratum_2,
	p.gender_concept_id AS stratum_3,
	FLOOR((YEAR(ce.condition_era_start_date) - p.year_of_birth) / 10) AS stratum_4,
	COUNT_BIG(DISTINCT p.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN 
	@cdmDatabaseSchema.condition_era ce 
ON 
	p.person_id = ce.person_id
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	ce.person_id = op.person_id
AND 
	ce.condition_era_start_date >= op.observation_period_start_date
AND 
	ce.condition_era_start_date <= op.observation_period_end_date	
GROUP BY 
	ce.condition_concept_id,
	YEAR(ce.condition_era_start_date),
	p.gender_concept_id,
	FLOOR((YEAR(ce.condition_era_start_date) - p.year_of_birth) / 10)
)
SELECT
	1004 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) AS stratum_3,
	CAST(stratum_4 AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1004
FROM 
	rawData;

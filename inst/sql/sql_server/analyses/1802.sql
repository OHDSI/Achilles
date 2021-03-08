-- 1802	Number of persons by measurement occurrence start month, by measurement_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	m.measurement_concept_id AS stratum_1,
	YEAR(m.measurement_date) * 100 + MONTH(m.measurement_date) AS stratum_2,
	COUNT_BIG(DISTINCT m.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.measurement m
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
	YEAR(m.measurement_date) * 100 + MONTH(m.measurement_date)
)
SELECT
  1802 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1802
FROM 
	rawData;

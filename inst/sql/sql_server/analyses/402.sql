-- 402	Number of persons by condition occurrence start month, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	co.condition_concept_id AS stratum_1,
	YEAR(co.condition_start_date) * 100 + MONTH(co.condition_start_date) AS stratum_2,
	COUNT_BIG(DISTINCT co.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.condition_occurrence co
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	co.person_id = op.person_id
AND 
	co.condition_start_date >= op.observation_period_start_date
AND 
	co.condition_start_date <= op.observation_period_end_date
GROUP BY 
	co.condition_concept_id,
	YEAR(co.condition_start_date) * 100 + MONTH(co.condition_start_date)
)
SELECT
  402 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_402
FROM 
	rawData;

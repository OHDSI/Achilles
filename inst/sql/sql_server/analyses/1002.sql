-- 1002	Number of persons by condition occurrence start month, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	ce.condition_concept_id AS stratum_1,
	YEAR(ce.condition_era_start_date) * 100 + MONTH(ce.condition_era_start_date) AS stratum_2,
	COUNT_BIG(DISTINCT ce.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.condition_era ce
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
	YEAR(ce.condition_era_start_date) * 100 + MONTH(ce.condition_era_start_date)
)
SELECT
  1002 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1002
FROM 
	rawData;

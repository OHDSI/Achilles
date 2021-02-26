-- 802	Number of persons by observation occurrence start month, by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	o.observation_concept_id AS stratum_1,
	YEAR(o.observation_date) * 100 + MONTH(o.observation_date) AS stratum_2,
	COUNT_BIG(DISTINCT o.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.observation o
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	o.person_id = op.person_id
AND 
	o.observation_date >= op.observation_period_start_date
AND 
	o.observation_date <= op.observation_period_end_date
GROUP BY 
	o.observation_concept_id,
	YEAR(o.observation_date) * 100 + MONTH(o.observation_date)
)
SELECT
  802 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_802
FROM 
	rawData;

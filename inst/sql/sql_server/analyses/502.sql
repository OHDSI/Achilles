-- 502	Number of persons by death month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(d.death_date) * 100 + MONTH(d.death_date) AS stratum_1,
	COUNT_BIG(DISTINCT d.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.death d
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	d.person_id = op.person_id
AND 
	d.death_date >= op.observation_period_start_date
AND 
	d.death_date <= op.observation_period_end_date	
GROUP BY 
	YEAR(d.death_date) * 100 + MONTH(d.death_date)
)
SELECT
  502 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(NULL AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_502
FROM 
	rawData;

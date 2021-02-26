-- 202	Number of persons by visit occurrence start month, by visit_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	vo.visit_concept_id AS stratum_1,
	YEAR(vo.visit_start_date) * 100 + MONTH(vo.visit_start_date) AS stratum_2,
	COUNT_BIG(DISTINCT vo.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.visit_occurrence vo
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
	YEAR(vo.visit_start_date) * 100 + MONTH(vo.visit_start_date)
)
SELECT
  202 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_202
FROM 
	rawData;

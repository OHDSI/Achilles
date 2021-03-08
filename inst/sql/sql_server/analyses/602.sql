-- 602	Number of persons by procedure occurrence start month, by procedure_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	po.procedure_concept_id AS stratum_1,
	YEAR(po.procedure_date) * 100 + MONTH(po.procedure_date) AS stratum_2,
	COUNT_BIG(DISTINCT po.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.procedure_occurrence po
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	po.person_id = op.person_id
AND 
	po.procedure_date >= op.observation_period_start_date
AND 
	po.procedure_date <= op.observation_period_end_date
GROUP BY 
	po.procedure_concept_id,
	YEAR(po.procedure_date) * 100 + MONTH(po.procedure_date)
)
SELECT
  602 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS varchar(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_602
FROM 
	rawData;

-- 1321	Number of persons by visit start year 

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(visit_detail_start_date) AS stratum_1,
	COUNT_BIG(DISTINCT person_id) AS count_value
FROM 
	@cdmDatabaseSchema.visit_detail
GROUP BY 
	YEAR(visit_detail_start_date)
)
SELECT
  1321 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(NULL AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1321
FROM 
	rawData;

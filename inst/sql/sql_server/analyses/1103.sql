-- 1103	Number of care sites by location state

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
  1103 AS analysis_id,
  CAST(l1.state AS VARCHAR(255)) AS stratum_1,
  CAST(cs1.location_id AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  COUNT_BIG(DISTINCT cs1.care_site_id) AS count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1103
FROM @cdmDatabaseSchema.care_site cs1
INNER JOIN @cdmDatabaseSchema.location l1
  ON cs1.location_id = l1.location_id
WHERE cs1.location_id IS NOT NULL
  AND l1.state IS NOT NULL
GROUP BY l1.state, cs1.location_id;
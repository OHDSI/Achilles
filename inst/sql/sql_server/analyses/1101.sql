-- 1101	Number of persons by location state

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
  1101 AS analysis_id,
  CAST(l1.state AS VARCHAR(255)) AS stratum_1,
  CAST(l1.location_id AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  COUNT_BIG(DISTINCT p1.person_id) AS count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1101
FROM @cdmDatabaseSchema.person p1
INNER JOIN @cdmDatabaseSchema.location l1
  ON p1.location_id = l1.location_id
WHERE p1.location_id IS NOT NULL
  AND l1.state IS NOT NULL
GROUP BY l1.state, l1.location_id;
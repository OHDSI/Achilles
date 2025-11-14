-- 1102	Number of care sites by location 3-digit zip

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
    LEFT(l1.zip, 3) AS stratum_1,
    cs1.location_id AS stratum_2,
    COUNT_BIG(DISTINCT cs1.care_site_id) AS count_value
  FROM @cdmDatabaseSchema.care_site cs1
  INNER JOIN @cdmDatabaseSchema.location l1
    ON cs1.location_id = l1.location_id
  WHERE cs1.location_id IS NOT NULL
    AND l1.zip IS NOT NULL
  GROUP BY LEFT(l1.zip, 3), cs1.location_id
)
SELECT
  1102 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1102
FROM rawData;


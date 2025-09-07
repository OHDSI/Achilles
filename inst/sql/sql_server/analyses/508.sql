-- 508 Deaths by cause and calendar month (YYYYMM format)

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT
    d.cause_concept_id AS stratum_1,
    YEAR(d.death_date) * 100 + MONTH(d.death_date) AS stratum_2,
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
WHERE
    d.cause_concept_id IS NOT NULL
    AND d.cause_concept_id != 0
    AND d.death_date IS NOT NULL
GROUP BY
    d.cause_concept_id, YEAR(d.death_date) * 100 + MONTH(d.death_date)
)
SELECT
  508 AS analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,  -- cause_concept_id
  CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,  -- YYYYMM
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  CAST(NULL AS VARCHAR(255)) AS stratum_4,
  CAST(NULL AS VARCHAR(255)) AS stratum_5,
  count_value
INTO
    @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_508
FROM
    rawData;
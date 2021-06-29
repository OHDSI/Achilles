-- 2001	patients with at least 1 Dx and 1 Proc


SELECT 
	2001 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	CAST(d.cnt AS BIGINT) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2001
FROM (
SELECT COUNT_BIG(*) cnt
FROM (
  SELECT DISTINCT person_id
	FROM (
    SELECT
      co.person_id
    FROM
      @cdmDatabaseSchema.condition_occurrence co
    JOIN
      @cdmDatabaseSchema.observation_period op
    ON
      co.person_id = op.person_id
    AND
      co.condition_start_date >= op.observation_period_start_date
    AND
      co.condition_start_date <= op.observation_period_end_date
  ) a

	INTERSECT
	
	SELECT DISTINCT person_id
	FROM (
    SELECT
      po.person_id
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
    ) b
	) c
) d;

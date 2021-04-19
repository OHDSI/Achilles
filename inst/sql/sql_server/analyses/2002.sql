-- 2002	patients with at least 1 Mes and 1 Dx and 1 Rx


SELECT 
	2002 AS analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	CAST(e.cnt AS BIGINT) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2002
FROM (
SELECT COUNT_BIG(*) cnt
FROM (
	SELECT DISTINCT person_id
	FROM (
    SELECT
      m.person_id
    FROM
      @cdmDatabaseSchema.measurement m
    JOIN
      @cdmDatabaseSchema.observation_period op
    ON
      m.person_id = op.person_id
    AND
      m.measurement_date >= op.observation_period_start_date
    AND
      m.measurement_date <= op.observation_period_end_date
    ) a

	INTERSECT

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
    ) b

	INTERSECT

	SELECT DISTINCT person_id
	FROM (
    SELECT
      de.person_id
    FROM
      @cdmDatabaseSchema.drug_exposure de
    JOIN
      @cdmDatabaseSchema.observation_period op
    ON
      de.person_id = op.person_id
    AND
      de.drug_exposure_start_date >= op.observation_period_start_date
    AND
      de.drug_exposure_start_date <= op.observation_period_end_date
    ) c
	) d
) e;

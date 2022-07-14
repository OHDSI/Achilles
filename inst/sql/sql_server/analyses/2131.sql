-- 2131	Proportion of people with at least one device_exposure record outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of people with a record outside a valid observation period (numerator)
-- stratum_3:   Number of people in device_exposure (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(DISTINCT de.person_id) AS person_count
FROM 
	@cdmDatabaseSchema.device_exposure de
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.device_exposure_start_date >= op.observation_period_start_date
AND 
	de.device_exposure_start_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), de_total AS (
SELECT
	COUNT_BIG(DISTINCT person_id) person_count
FROM
	@cdmDatabaseSchema.device_exposure
)
SELECT 
	2131 AS analysis_id,
	CASE WHEN det.person_count != 0 THEN
		CAST(CAST(1.0*op.person_count/det.person_count AS FLOAT) AS VARCHAR(255)) 
	ELSE
		CAST(NULL AS VARCHAR(255)) 
	END AS stratum_1, 
	CAST(op.person_count AS VARCHAR(255)) AS stratum_2,
	CAST(det.person_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.person_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2131
FROM 
	op_outside op
CROSS JOIN 
	de_total det
;

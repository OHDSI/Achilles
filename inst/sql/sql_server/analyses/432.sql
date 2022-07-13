-- 432	Proportion of condition_occurrence records outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of condition_occurrence records outside a valid observation period (numerator)
-- stratum_3:   Number of condition_occurrence records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.condition_occurrence co
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	co.person_id = op.person_id
AND 
	co.condition_start_date >= op.observation_period_start_date
AND 
	co.condition_start_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), co_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.condition_occurrence
)
SELECT 
	432 AS analysis_id,
	CASE WHEN co.record_count != 0 THEN 
		CAST(CAST(1.0*op.record_count/co.record_count AS FLOAT) AS VARCHAR(255)) 
	ELSE
		CAST(NULL AS VARCHAR(255))
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(co.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_432
FROM 
	op_outside op
CROSS JOIN 
	co_total co
;

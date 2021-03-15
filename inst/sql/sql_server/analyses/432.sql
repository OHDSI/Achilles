-- 432	Proportion of condition_occurrence records with an observation period violation
--
-- stratum_1:   Proportion
-- stratum_2:   Number of observation period violations (numerator)
-- stratum_3:   Number of condition_occurrence records (denominator)
-- count_value: Flag (0 or 1) indicating whether any violations exist
--

WITH op_violations AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.condition_occurrence co
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	op.person_id = co.person_id
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
	CAST(1.0*opv.record_count/cot.record_count AS VARCHAR(255)) AS stratum_1, 
	CAST(opv.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(cot.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(opv.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_432
FROM 
	op_violations opv
CROSS JOIN 
	co_total cot
;
-- 431	Proportion of people with at least one condition_occurrence record outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of observation period violators (numerator)
-- stratum_3:   Number of people in condition_occurrence (denominator)
-- count_value: Flag (0 or 1) indicating whether any violators exist
--

WITH op_violators AS (
SELECT 
	COUNT_BIG(DISTINCT co.person_id) AS person_count
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
	COUNT_BIG(DISTINCT person_id) person_count
FROM
	@cdmDatabaseSchema.condition_occurrence
)
SELECT 
	431 AS analysis_id,
	CAST(1.0*opv.person_count/cot.person_count AS VARCHAR(255)) AS stratum_1, 
	CAST(opv.person_count AS VARCHAR(255)) AS stratum_2,
	CAST(cot.person_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(opv.person_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_431
FROM 
	op_violators opv
CROSS JOIN 
	co_total cot

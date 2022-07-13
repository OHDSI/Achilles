-- 832	Proportion of observation records outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of observation records outside a valid observation period (numerator)
-- stratum_3:   Number of observation records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.observation o
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	o.person_id = op.person_id
AND 
	o.observation_date >= op.observation_period_start_date
AND 
	o.observation_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), o_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.observation
)
SELECT 
	832 AS analysis_id,
	CASE WHEN ot.record_count != 0 THEN 
		CAST(CAST(1.0*op.record_count/ot.record_count AS FLOAT) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255)) 
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(ot.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_832
FROM 
	op_outside op
CROSS JOIN 
	o_total ot
;

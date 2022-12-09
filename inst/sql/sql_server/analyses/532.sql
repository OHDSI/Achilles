-- 532	Proportion of death records outside a valid observation period
--
-- stratum_1:   Proportion to 6 decimal places
-- stratum_2:   Number of death records outside a valid observation period (numerator)
-- stratum_3:   Number of death records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such rceords exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.death d
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	d.person_id = op.person_id
AND 
	d.death_date >= op.observation_period_start_date
AND 
	d.death_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), death_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.death
)
SELECT 
	532 AS analysis_id,
	CASE WHEN dt.record_count != 0 THEN
		CAST(CAST(1.0*op.record_count/dt.record_count AS FLOAT) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255))
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(dt.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_532
FROM 
	op_outside op
CROSS JOIN 
	death_total dt
;

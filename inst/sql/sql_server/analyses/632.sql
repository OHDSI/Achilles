-- 632	Proportion of procedure_occurrence records outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of procedure_occurrence records outside a valid observation period (numerator)
-- stratum_3:   Number of procedure_occurrence records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.procedure_occurrence po
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	po.person_id = op.person_id
AND 
	po.procedure_date >= op.observation_period_start_date
AND 
	po.procedure_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), po_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.procedure_occurrence
)
SELECT 
	632 AS analysis_id,
	CASE WHEN po.record_count != 0 THEN 
		CAST(CAST(1.0*op.record_count/po.record_count AS FLOAT) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255)) 
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(po.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_632
FROM 
	op_outside op
CROSS JOIN 
	po_total po
;

-- 1332	Proportion of visit_detail records outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of visit_detail records outside a valid observation period (numerator)
-- stratum_3:   Number of visit_detail records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.visit_detail vd
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vd.person_id = op.person_id
AND 
	vd.visit_detail_start_date >= op.observation_period_start_date
AND 
	vd.visit_detail_start_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), vd_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.visit_detail
)
SELECT 
	1332 AS analysis_id,
	CASE WHEN vdt.record_count != 0 THEN 
		CAST(CAST(1.0*op.record_count/vdt.record_count AS FLOAT) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255)) 
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(vdt.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1332
FROM 
	op_outside op
CROSS JOIN 
	vd_total vdt
;

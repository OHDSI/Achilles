-- 1331	Proportion of people with at least one visit_detail record outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of people with a record outside a valid observation period (numerator)
-- stratum_3:   Number of people in visit_detail (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(DISTINCT vd.person_id) AS person_count
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
	COUNT_BIG(DISTINCT person_id) person_count
FROM
	@cdmDatabaseSchema.visit_detail
)
SELECT 
	1331 AS analysis_id,
	CASE WHEN vdt.person_count != 0 THEN 
		CAST(CAST(1.0*op.person_count/vdt.person_count AS FLOAT) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255))
	END AS stratum_1, 
	CAST(op.person_count AS VARCHAR(255)) AS stratum_2,
	CAST(vdt.person_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.person_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1331
FROM 
	op_outside op
CROSS JOIN 
	vd_total vdt
;

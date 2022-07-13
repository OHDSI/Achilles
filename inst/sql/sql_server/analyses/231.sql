-- 231	Proportion of people with at least one visit_occurrence record outside a valid observation period
--
-- stratum_1:   Proportion
-- stratum_2:   Number of people with a record outside a valid observation period (numerator)
-- stratum_3:   Number of people in visit_occurrence (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(DISTINCT vo.person_id) AS person_count
FROM 
	@cdmDatabaseSchema.visit_occurrence vo
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vo.person_id = op.person_id
AND 
	vo.visit_start_date >= op.observation_period_start_date
AND 
	vo.visit_start_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), vo_total AS (
SELECT
	COUNT_BIG(DISTINCT person_id) person_count
FROM
	@cdmDatabaseSchema.visit_occurrence
)
SELECT 
	231 AS analysis_id,
	CASE WHEN vo.person_count != 0 THEN 
		CAST(CAST(1.0*op.person_count/vo.person_count AS FLOAT) AS VARCHAR(255)) 
	ELSE
		CAST(NULL AS VARCHAR(255)) 
	END AS stratum_1, 
	CAST(op.person_count AS VARCHAR(255)) AS stratum_2,
	CAST(vo.person_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.person_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_231
FROM 
	op_outside op
CROSS JOIN 
	vo_total vo
;

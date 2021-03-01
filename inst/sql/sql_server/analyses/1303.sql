-- 1303	Number of distinct visit detail concepts per person

--HINT DISTRIBUTE_ON_KEY(count_value)
with rawData(person_id, count_value) as
(
SELECT 
	vd.person_id,
	COUNT_BIG(DISTINCT vd.visit_detail_concept_id) AS count_value
FROM 
	@cdmDatabaseSchema.visit_detail vd
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	vd.person_id = op.person_id
AND	
	vd.visit_detail_start_date >= op.observation_period_start_date  
AND 
	vd.visit_detail_start_date <= op.observation_period_end_date
GROUP BY 
	vd.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) AS
(
SELECT 
	CAST(AVG(1.0 * count_value) AS FLOAT) AS avg_value,
	CAST(stdev(count_value) AS FLOAT) AS stdev_value,
	MIN(count_value) AS min_value,
	MAX(count_value) AS max_value,
	COUNT_BIG(*) AS total
FROM 
	rawData
),
statsView (count_value, total, rn) AS
(
SELECT 
	count_value,
	COUNT_BIG(*) AS total,
	ROW_NUMBER() OVER (ORDER BY count_value) AS rn
FROM 
	rawData
GROUP BY 
	count_value
),
priorStats (count_value, total, accumulated) AS
(
SELECT 
	s.count_value,
	s.total,
	SUM(p.total) AS accumulated
FROM 
	statsView s
JOIN 
	statsView p ON p.rn <= s.rn
GROUP BY 
	s.count_value,
	s.total,
	s.rn
)
SELECT 
	1303 AS analysis_id,
	o.total AS count_value,
	o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(CASE WHEN p.accumulated >= .50 * o.total THEN count_value ELSE o.max_value END) AS median_value,
	MIN(CASE WHEN p.accumulated >= .10 * o.total THEN count_value ELSE o.max_value END) AS p10_value,
	MIN(CASE WHEN p.accumulated >= .25 * o.total THEN count_value ELSE o.max_value END) AS p25_value,
	MIN(CASE WHEN p.accumulated >= .75 * o.total THEN count_value ELSE o.max_value END) AS p75_value,
	MIN(CASE WHEN p.accumulated >= .90 * o.total THEN count_value ELSE o.max_value END) AS p90_value
INTO 
	#tempResults_1303
FROM 
	priorStats p
CROSS JOIN 
	overallStats o
GROUP BY 
	o.total,
	o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(count_value)
SELECT 
	analysis_id,
	CAST(NULL AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value,
	min_value,
	max_value,
	avg_value,
	stdev_value,
	median_value,
	p10_value,
	p25_value,
	p75_value,
	p90_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1303
FROM 
	#tempResults_1303
;

TRUNCATE TABLE #tempResults_1303;
DROP TABLE #tempResults_1303;

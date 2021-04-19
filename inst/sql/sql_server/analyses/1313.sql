-- 1313	Distribution of length of stay by visit_detail_concept_id
-- restrict to visits inside observation period

--HINT DISTRIBUTE_ON_KEY(stratum_id) 
WITH rawData(stratum_id, count_value) AS
(
SELECT 
	vd.visit_detail_concept_id AS stratum_id,
	DATEDIFF(dd, vd.visit_detail_start_date, vd.visit_detail_END_date) AS count_value
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
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) AS
(
SELECT 
	stratum_id,
	CAST(AVG(1.0 * count_value) AS FLOAT) AS avg_value,
	CAST(STDEV(count_value) AS FLOAT) AS stdev_value,
	MIN(count_value) AS min_value,
	MAX(count_value) AS max_value,
	COUNT_BIG(*) AS total
FROM 
	rawData
GROUP BY 
	stratum_id
),
statsView (stratum_id, count_value, total, rn) AS
(
SELECT 
	stratum_id,
	count_value,
	COUNT_BIG(*) AS total,
	ROW_NUMBER() OVER (ORDER BY count_value) AS rn
FROM 
	rawData
GROUP BY 
	stratum_id,
	count_value
),
priorStats (stratum_id, count_value, total, accumulated) AS
(
SELECT 
	s.stratum_id,
	s.count_value,
	s.total,
	SUM(p.total) AS accumulated
FROM 
	statsView s
JOIN 
	statsView p 
ON 
	s.stratum_id = p.stratum_id
AND 
	p.rn <= s.rn
GROUP BY 
	s.stratum_id,
	s.count_value,
	s.total,
	s.rn
)
select 
	1313 AS analysis_id,
	CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
	o.total as count_value,
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
	#tempResults_1313
FROM 
	priorStats p
JOIN 
	overallStats o ON p.stratum_id = o.stratum_id
GROUP BY 
	o.stratum_id, 
	o.total, 
	o.min_value, 
	o.max_value, 
	o.avg_value, 
	o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1) 
SELECT 
	analysis_id,
	stratum_id AS stratum_1,
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
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1313
FROM 
	#tempResults_1313;

TRUNCATE TABLE #tempResults_1313;
DROP TABLE #tempResults_1313;

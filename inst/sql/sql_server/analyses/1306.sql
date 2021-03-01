-- 1306	Distribution of age by visit_detail_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
WITH rawData (stratum1_id, stratum2_id, count_value) AS
(
SELECT 
	vd.visit_detail_concept_id AS stratum1_id,
	p.gender_concept_id AS stratum2_id,
	vd.visit_detail_start_year - p.year_of_birth AS count_value
FROM 
	@cdmDatabaseSchema.person p
JOIN (
	SELECT 
		vd.person_id,
		vd.visit_detail_concept_id,
		MIN(YEAR(vd.visit_detail_start_date)) AS visit_detail_start_year
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
		vd.person_id,
		vd.visit_detail_concept_id
	) vd 
ON 
	p.person_id = vd.person_id
),
overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) AS
(
SELECT 
	stratum1_id,
	stratum2_id,
	CAST(AVG(1.0 * count_value) AS FLOAT) AS avg_value,
	CAST(STDEV(count_value) AS FLOAT) AS stdev_value,
	MIN(count_value) AS min_value,
	MAX(count_value) AS max_value,
	COUNT_BIG(*) AS total
FROM 
	rawData
GROUP BY 
	stratum1_id,
	stratum2_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) AS
(
SELECT 
	stratum1_id,
	stratum2_id,
	count_value,
	COUNT_BIG(*) AS total,
	ROW_NUMBER() OVER (PARTITION BY stratum1_id,stratum2_id ORDER BY count_value) AS rn
FROM 
	rawData
GROUP BY 
	stratum1_id,
	stratum2_id,
	count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) AS
(
SELECT 
	s.stratum1_id,
	s.stratum2_id,
	s.count_value,
	s.total,
	SUM(p.total) AS accumulated
FROM 
	statsView s
JOIN 
	statsView p ON s.stratum1_id = p.stratum1_id 
				AND s.stratum2_id = p.stratum2_id 
				AND p.rn <= s.rn
GROUP BY 
	s.stratum1_id,
	s.stratum2_id,
	s.count_value,
	s.total,
	s.rn
)
SELECT 
	1306 AS analysis_id,
	CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
	CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
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
	#tempResults_1306
FROM 
	priorStats p
JOIN 
	overallStats o ON p.stratum1_id = o.stratum1_id AND p.stratum2_id = o.stratum2_id 
GROUP BY 
	o.stratum1_id, 
	o.stratum2_id, 
	o.total, 
	o.min_value, 
	o.max_value, 
	o.avg_value, 
	o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT 
	analysis_id,
	stratum1_id AS stratum_1,
	stratum2_id AS stratum_2,
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
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1306
FROM 
	#tempResults_1306
;

TRUNCATE TABLE #tempResults_1306;
DROP TABLE #tempResults_1306;

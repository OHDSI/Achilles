-- 1816	Distribution of low range, by measurement_concept_id and unit_concept_id


--HINT DISTRIBUTE_ON_KEY(stratum1_id)
SELECT 
	m.subject_id AS stratum1_id,
	m.unit_concept_id AS stratum2_id,
	CAST(AVG(1.0 * m.count_value) AS FLOAT) AS avg_value,
	CAST(STDEV(m.count_value) AS FLOAT) AS stdev_value,
	MIN(m.count_value) AS min_value,
	MAX(m.count_value) AS max_value,
	COUNT_BIG(*) AS total
INTO 
	#overallStats_1816
FROM (
	SELECT 
		m.measurement_concept_id AS subject_id,
		m.unit_concept_id,
		CAST(m.range_low AS FLOAT) AS count_value
	FROM 
		@cdmDatabaseSchema.measurement m
	JOIN 
		@cdmDatabaseSchema.observation_period op 
	ON 
		m.person_id = op.person_id
	AND 
		m.measurement_date >= op.observation_period_start_date
	AND 
		m.measurement_date <= op.observation_period_end_date		
	WHERE 
		m.unit_concept_id IS NOT NULL
	AND 
		m.value_as_number IS NOT NULL
	AND 
		m.range_low IS NOT NULL
	AND 
		m.range_high IS NOT NULL
	) m
GROUP BY 
	m.subject_id, 
	m.unit_concept_id
;

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
SELECT 
	m.subject_id AS stratum1_id,
	m.unit_concept_id AS stratum2_id,
	m.count_value,
	COUNT_BIG(*) AS total,
	ROW_NUMBER() OVER (PARTITION BY m.subject_id,m.unit_concept_id ORDER BY m.count_value) AS rn
INTO 
	#statsView_1816
FROM (
	SELECT 
		m.measurement_concept_id AS subject_id,
		m.unit_concept_id,
		CAST(m.range_low AS FLOAT) AS count_value
	FROM 
		@cdmDatabaseSchema.measurement m
  	JOIN 
		@cdmDatabaseSchema.observation_period op 
	ON 
		m.person_id = op.person_id
	AND 
		m.measurement_date >= op.observation_period_start_date
	AND 
		m.measurement_date <= op.observation_period_end_date		
	WHERE 
		m.unit_concept_id IS NOT NULL
	AND 
		m.value_as_number IS NOT NULL
	AND 
		m.range_low IS NOT NULL
	AND 
		m.range_high IS NOT NULL
	) m
GROUP BY 
	m.subject_id, 
	m.unit_concept_id, 
	m.count_value
;

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
select 1816 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults_1816
from 
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from #statsView_1816 s
  join #statsView_1816 p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
) p
join #overallStats_1816 o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 
  analysis_id, stratum1_id as stratum_1, stratum2_id as stratum_2, 
  cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
  count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1816
from #tempResults_1816
;

truncate table #overallStats_1816;
drop table #overallStats_1816;

truncate table #statsView_1816;
drop table #statsView_1816;

truncate table #tempResults_1816;
drop table #tempResults_1816;

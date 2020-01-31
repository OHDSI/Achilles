-- 106	Length of observation (days) of first observation period by gender

--HINT DISTRIBUTE_ON_KEY(gender_concept_id)
select p.gender_concept_id, op.count_value
into #rawData_106
FROM
(
  select person_id, DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
    ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
  from @cdmDatabaseSchema.observation_period op
) op
JOIN @cdmDatabaseSchema.person p on op.person_id = p.person_id
where op.rn = 1
;

--HINT DISTRIBUTE_ON_KEY(gender_concept_id)
with overallStats (gender_concept_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select gender_concept_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_106
  group by gender_concept_id
),
statsView (gender_concept_id, count_value, total, rn) as
(
  select gender_concept_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM #rawData_106
  group by gender_concept_id, count_value
),
priorStats (gender_concept_id,count_value, total, accumulated) as
(
  select s.gender_concept_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.gender_concept_id = p.gender_concept_id and p.rn <= s.rn
  group by s.gender_concept_id, s.count_value, s.total, s.rn
)
select 106 as analysis_id,
  CAST(o.gender_concept_id AS VARCHAR(255)) as gender_concept_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value end) as p90_value
INTO #tempResults_106
from priorStats p
join overallStats o on p.gender_concept_id = o.gender_concept_id
GROUP BY o.gender_concept_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, gender_concept_id as stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_106
FROM #tempResults_106
;

truncate table #rawData_106;
drop table #rawData_106;

truncate table #tempResults_106;
drop table #tempResults_106;

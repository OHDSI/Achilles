-- 213	Distribution of length of stay by visit_concept_id
-- restrict to visits inside observation period

--HINT DISTRIBUTE_ON_KEY(stratum_id) 
with rawData(stratum_id, count_value) as
(
  select visit_concept_id AS stratum_id, datediff(dd,visit_start_date,visit_end_date) as count_value
  from @cdmDatabaseSchema.visit_occurrence vo inner join 
  @cdmDatabaseSchema.observation_period op on vo.person_id = op.person_id
  -- only include events that occur during observation period
  where vo.visit_start_date >= op.observation_period_start_date and
  isnull(vo.visit_end_date,vo.visit_start_date) <= op.observation_period_end_date
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
  group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 213 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
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
into #tempResults_213
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1) 
select analysis_id, stratum_id as stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_213
from #tempResults_213
;

truncate table #tempResults_213;
drop table #tempResults_213;

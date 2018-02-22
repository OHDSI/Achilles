-- 105	Length of observation (days) of first observation period

with rawData (count_value) as
(
  select count_value
  FROM
  (
    select DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
  	  ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
    from @cdmDatabaseSchema.OBSERVATION_PERIOD op
	) op
	where op.rn = 1
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
  CAST(stdev(count_value) AS FLOAT) as stdev_value,
  min(count_value) as min_value,
  max(count_value) as max_value,
  count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM
  (
    select DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
  	  ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
    from @cdmDatabaseSchema.OBSERVATION_PERIOD op
	) op
  where op.rn = 1
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 105 as analysis_id,
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
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select analysis_id,
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5, count_value,
min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_105
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

-- 105	Length of observation (days) of first observation period

--HINT DISTRIBUTE_ON_KEY(count_value)
select count_value, rn 
into #tempObs_105
FROM
(
  select DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
	  ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
  from @cdmDatabaseSchema.observation_period op
) A
where rn = 1;
	
select count_value, count_big(*) as total, row_number() over (order by count_value) as rn
into #statsView_105
FROM #tempObs_105
group by count_value;

--HINT DISTRIBUTE_ON_KEY(count_value)
with overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
  CAST(stdev(count_value) AS FLOAT) as stdev_value,
  min(count_value) as min_value,
  max(count_value) as max_value,
  count_big(*) as total
  from #tempObs_105
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from #statsView_105 s
  join #statsView_105 p on p.rn <= s.rn
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
into #tempResults_105
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(count_value)
select analysis_id,
cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5, count_value,
min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_105
from #tempResults_105
;

truncate table #tempObs_105;
drop table #tempObs_105;

truncate table #statsView_105;
drop table #statsView_105;

truncate table #tempResults_105;
drop table #tempResults_105;

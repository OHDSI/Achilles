-- 1608	Distribution of total_paid by procedure_concept_id

with rawData(stratum1_id, count_value) as
(
 select po.procedure_concept_id     as stratum1_id,
        c.total_paid           as count_value
  from @cdmDatabaseSchema.cost c
  join @cdmDatabaseSchema.procedure_occurrence po
    on c.cost_event_id = po.procedure_occurrence_id
 where c.cost_domain_id = 'Procedure'
   and c.total_paid is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    avg(1.0 * count_value) as avg_value,
    stdev(count_value) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
stats (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
		count_value, 
  	    count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  from rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from stats s
  join stats p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 
	1608          as analysis_id,
	p.stratum1_id as stratum_1,
    o.total       as count_value,
    o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults_1608
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
group by p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, 
cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1608
from #tempResults_1608
;

truncate table #tempResults_1608;
drop table #tempResults_1608;

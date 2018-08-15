-- 511	Distribution of time from death to last condition

--HINT DISTRIBUTE_ON_KEY(count_value)
select 511 as analysis_id,
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	CAST(avg(1.0*count_value) AS FLOAT) as avg_value,
	CAST(stdev(count_value) AS FLOAT) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_511
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(*) over () + 1) as p1
from @cdmDatabaseSchema.death d1
	inner join
	(
		select person_id, max(condition_start_date) as max_date
		from @cdmDatabaseSchema.condition_occurrence
		group by person_id
	) t0 on d1.person_id = t0.person_id
) t1
;

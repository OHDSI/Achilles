-- 907	Distribution of drug era length, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData(stratum1_id, count_value) AS
(
SELECT 
	de.drug_concept_id AS stratum1_id,
	DATEDIFF(dd, de.drug_era_start_date, de.drug_era_end_date) AS count_value
FROM 
	@cdmDatabaseSchema.drug_era de
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.drug_era_start_date >= op.observation_period_start_date
AND 
	de.drug_era_start_date <= op.observation_period_end_date
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
  	CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
		count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 907 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
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
into #tempResults_907
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_907
from #tempResults_907
;

truncate table #tempResults_907;
drop table #tempResults_907;

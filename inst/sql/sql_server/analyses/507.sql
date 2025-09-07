-- 507: Distribution of age at death by cause and gender

--HINT DISTRIBUTE_ON_KEY(stratum_id)
WITH rawData(stratum_id, stratum_id_2, count_value) AS
(
SELECT
    d.cause_concept_id AS stratum_id,
    p.gender_concept_id AS stratum_id_2,
    d.death_year - p.year_of_birth AS count_value
FROM
    @cdmDatabaseSchema.person p
JOIN (
    SELECT
       d.person_id,
       d.cause_concept_id,
       MIN(YEAR(d.death_date)) AS death_year
    FROM
       @cdmDatabaseSchema.death d
    JOIN
       @cdmDatabaseSchema.observation_period op
    ON
       d.person_id = op.person_id
    AND
       d.death_date >= op.observation_period_start_date
    AND
       d.death_date <= op.observation_period_end_date
    GROUP BY
       d.person_id, d.cause_concept_id
  ) d
ON
    p.person_id = d.person_id
WHERE
    d.cause_concept_id IS NOT NULL
    AND d.cause_concept_id != 0
    AND p.gender_concept_id IS NOT NULL
    AND p.gender_concept_id != 0
),
overallStats (stratum_id, stratum_id_2, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id, stratum_id_2,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
  group by stratum_id, stratum_id_2
),
statsView (stratum_id, stratum_id_2, count_value, total, rn) as
(
  select stratum_id, stratum_id_2, count_value, count_big(*) as total,
         row_number() over (partition by stratum_id, stratum_id_2 order by count_value) as rn
  FROM rawData
  group by stratum_id, stratum_id_2, count_value
),
priorStats (stratum_id, stratum_id_2, count_value, total, accumulated) as
(
  select s.stratum_id, s.stratum_id_2, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id
                   and s.stratum_id_2 = p.stratum_id_2
                   and p.rn <= s.rn
  group by s.stratum_id, s.stratum_id_2, s.count_value, s.total, s.rn
)
select 507 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  CAST(o.stratum_id_2 AS VARCHAR(255)) AS stratum_id_2,
  o.total as count_value,
  o.min_value,
    o.max_value,
    o.avg_value,
    o.stdev_value,
    MIN(case when ps.accumulated >= .50 * o.total then ps.count_value else o.max_value end) as median_value,
    MIN(case when ps.accumulated >= .10 * o.total then ps.count_value else o.max_value end) as p10_value,
    MIN(case when ps.accumulated >= .25 * o.total then ps.count_value else o.max_value end) as p25_value,
    MIN(case when ps.accumulated >= .75 * o.total then ps.count_value else o.max_value end) as p75_value,
    MIN(case when ps.accumulated >= .90 * o.total then ps.count_value else o.max_value end) as p90_value
into #tempResults_507
from overallStats o
join priorStats ps on o.stratum_id = ps.stratum_id and o.stratum_id_2 = ps.stratum_id_2
GROUP BY o.stratum_id, o.stratum_id_2, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, stratum_id as stratum_1,
stratum_id_2 as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_507
from #tempResults_507
;

truncate table #tempResults_507;

drop table #tempResults_507;
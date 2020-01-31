
-- overallStats

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
select 
  subject_id as stratum1_id, 
  CAST(avg(1.0 * @costColumn) AS FLOAT) as avg_value,
  CAST(stdev(@costColumn) AS FLOAT) as stdev_value,
  min(@costColumn) as min_value,
  max(@costColumn) as max_value,
  count_big(*) as total
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_overallStats_@analysisId
from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw
where @costColumn is not null
group by subject_id
;

-- statsView

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
select
  subject_id as stratum1_id, 
	@costColumn as count_value, 
  count_big(*) as total, 
	row_number() over (partition by subject_id order by @costColumn) as rn
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_statsView_@analysisId
from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw
group by subject_id, @costColumn
;

-- priorStats

--HINT DISTRIBUTE_ON_KEY(stratum1_id)
select 
  s.stratum1_id, 
  s.count_value, 
  s.total, 
  sum(p.total) as accumulated
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_priorStats_@analysisId
from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_statsView_@analysisId s 
join @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_statsView_@analysisId p
  on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
group by s.stratum1_id, s.count_value, s.total, s.rn
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 
  @analysisId as analysis_id,
	CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2,
	cast(null as varchar(255)) as stratum_3,
	cast(null as varchar(255)) as stratum_4,
	cast(null as varchar(255)) as stratum_5,
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
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_@analysisId
from @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_priorStats_@analysisId p 
join @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_overallStats_@analysisId o on p.stratum1_id = o.stratum1_id
group by p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

truncate table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_overallStats_@analysisId;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_overallStats_@analysisId;

truncate table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_statsView_@analysisId;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_statsView_@analysisId;

truncate table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_priorStats_@analysisId;
drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_priorStats_@analysisId;

IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_@analysisId', 'U') IS NOT NULL
	DROP TABLE @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_@analysisId;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
with cte_raw_@analysisId
as
(
  {@cdmVersion == '5'}?{
    select 
      @domain_concept_id as subject_id,
      @countValue
    from @cdmDatabaseSchema.@domain_cost A
    join @cdmDatabaseSchema.@domainTable B on A.@domainTable_id = B.@domainTable_id and B.@domain_concept_id <> 0
    where A.@countValue is not null
  }:{
    select  
      @domain_concept_id as subject_id,
      @costColumn as @countValue
    from @cdmDatabaseSchema.cost A
    join @cdmDatabaseSchema.@domainTable B on A.cost_event_id = B.@domainTable_id and B.@domain_concept_id <> 0
    where A.cost_domain_id = '@domain'
    and A.@costColumn is not null
  }
),
cte_overallstats
as
(
  select 
    subject_id as stratum1_id, 
    CAST(avg(1.0 * @countValue) AS FLOAT) as avg_value,
    CAST(stdev(@countValue) AS FLOAT) as stdev_value,
    min(@countValue) as min_value,
    max(@countValue) as max_value,
    @countValue as count_value,
    count_big(*) as total,
    row_number() over (partition by subject_id order by @countValue) as rn
  from cte_raw_@analysisId
  group by subject_id, @countValue
),
cte_priorstats
as
(
  select 
    s.stratum1_id, 
    s.count_value, 
    s.total, 
    sum(p.total) as accumulated
  from cte_overallstats s 
  join cte_overallstats p
    on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 
  @analysisId as analysis_id,
	CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
	null as stratum_2,
	null as stratum_3,
	null as stratum_4,
	null as stratum_5,
	o.total as count_value,
	o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then o.total else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then o.total else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then o.total else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then o.total else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then o.total else o.max_value end) as p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_@analysisId
from cte_priorstats p 
join cte_overallstats o on p.stratum1_id = o.stratum1_id
group by p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

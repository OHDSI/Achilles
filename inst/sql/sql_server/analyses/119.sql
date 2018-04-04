-- 119  Number of observation period records by period_type_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 119 as analysis_id,
  CAST(op1.period_type_concept_id AS VARCHAR(255)) as stratum_1,
  null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
  COUNT_BIG(*) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_119
from
  @cdmDatabaseSchema.observation_period op1
group by op1.period_type_concept_id
;

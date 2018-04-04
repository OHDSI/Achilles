-- 118  Number of observation period records with invalid person_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 118 as analysis_id,
  null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
  COUNT_BIG(op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_118
from
  @cdmDatabaseSchema.observation_period op1
  left join @cdmDatabaseSchema.PERSON p1
  on p1.person_id = op1.person_id
where p1.person_id is null
;

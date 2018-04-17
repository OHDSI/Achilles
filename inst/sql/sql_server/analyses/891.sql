-- 891	Number of total persons that have at least x observations

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 891 as analysis_id,   
	CAST(observation_concept_id as varchar(255)) as stratum_1,
	CAST(obs_cnt as varchar(255)) as stratum_2,
	null as stratum_3,
	null as stratum_4,
	null as stratum_5,
	sum(count(person_id)) over (partition by observation_concept_id order by obs_cnt desc) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_891
from 
(
  select
  o.observation_concept_id,
  count(o.observation_id) as obs_cnt,
  o.person_id
  from @cdmDatabaseSchema.observation o
  group by o.person_id, o.observation_concept_id
) cnt_q
group by cnt_q.observation_concept_id, cnt_q.obs_cnt
;

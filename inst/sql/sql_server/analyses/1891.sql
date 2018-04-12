-- 1891	Number of total persons that have at least x measurements

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1891 as analysis_id,   
	CAST(measurement_concept_id as varchar(255)) as stratum_1,
	CAST(meas_cnt as varchar(255)) as stratum_2,
	null as stratum_3,
	null as stratum_4,
	null as stratum_5,
	sum(count(person_id)) over (partition by measurement_concept_id order by meas_cnt desc) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1891
from 
(
  select
  m.measurement_concept_id,
  count(m.measurement_id) as meas_cnt,
  m.person_id
  from @cdmDatabaseSchema.measurement m
  group by m.person_id, m.measurement_concept_id
) cnt_q
group by cnt_q.measurement_concept_id, cnt_q.meas_cnt
;

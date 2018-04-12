-- 791	Number of total persons that have at least x drug exposures

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 791 as analysis_id,   
	CAST(drug_concept_id as varchar(255)) as stratum_1,
	CAST(drg_cnt as varchar(255)) as stratum_2,
	null as stratum_3,
	null as stratum_4,
	null as stratum_5,
	sum(count(person_id)) over (partition by drug_concept_id order by drg_cnt desc) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_791
from 
(
  select
  d.drug_concept_id,
  count(d.drug_exposure_id) as drg_cnt,
  d.person_id
  from @cdmDatabaseSchema.drug_exposure d
  group by d.person_id, d.drug_concept_id
) cnt_q
group by cnt_q.drug_concept_id, cnt_q.drg_cnt
;

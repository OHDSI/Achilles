-- 11	Number of non-deceased persons by year of birth and by gender

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 11 as analysis_id,  CAST(P.year_of_birth AS VARCHAR(255)) as stratum_1,
  CAST(P.gender_concept_id AS VARCHAR(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
  COUNT_BIG(distinct P.person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_11
from @cdmDatabaseSchema.person P
where not exists
(
  select 1
  from @cdmDatabaseSchema.death D
  where P.person_id = D.person_id
)
group by P.YEAR_OF_BIRTH, P.gender_concept_id;

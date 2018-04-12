-- 4	Number of persons by race

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 4 as analysis_id,  CAST(RACE_CONCEPT_ID AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_4
from @cdmDatabaseSchema.PERSON
group by RACE_CONCEPT_ID;

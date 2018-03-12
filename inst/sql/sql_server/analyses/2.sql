-- 2	Number of persons by gender

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 2 as analysis_id, 
CAST(gender_concept_id AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2
from @cdmDatabaseSchema.PERSON
group by GENDER_CONCEPT_ID;
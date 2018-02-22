-- 12	Number of persons by race and ethnicity

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 12 as analysis_id, CAST(RACE_CONCEPT_ID AS VARCHAR(255)) as stratum_1, CAST(ETHNICITY_CONCEPT_ID AS VARCHAR(255)) as stratum_2, 
null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_12
from @cdmDatabaseSchema.PERSON
group by RACE_CONCEPT_ID,ETHNICITY_CONCEPT_ID;

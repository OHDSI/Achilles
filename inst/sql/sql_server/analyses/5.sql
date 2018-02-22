-- 5	Number of persons by ethnicity

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 5 as analysis_id,  CAST(ETHNICITY_CONCEPT_ID AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_5
from @cdmDatabaseSchema.PERSON
group by ETHNICITY_CONCEPT_ID;

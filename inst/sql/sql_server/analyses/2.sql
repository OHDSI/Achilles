-- 2	Number of persons by gender

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 2 as analysis_id, 
CAST(gender_concept_id AS VARCHAR(255)) as stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2
from @cdmDatabaseSchema.person
group by GENDER_CONCEPT_ID;

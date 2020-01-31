-- 5	Number of persons by ethnicity

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 5 as analysis_id,  CAST(ETHNICITY_CONCEPT_ID AS VARCHAR(255)) as stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_5
from @cdmDatabaseSchema.person
group by ETHNICITY_CONCEPT_ID;

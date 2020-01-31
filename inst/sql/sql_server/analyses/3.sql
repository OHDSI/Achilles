-- 3	Number of persons by year of birth

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 3 as analysis_id,  CAST(year_of_birth AS VARCHAR(255)) as stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_3
from @cdmDatabaseSchema.person
group by YEAR_OF_BIRTH;

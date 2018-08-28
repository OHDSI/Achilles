-- 3	Number of persons by year of birth

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 3 as analysis_id,  CAST(year_of_birth AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_3
from @cdmDatabaseSchema.PERSON
group by YEAR_OF_BIRTH;

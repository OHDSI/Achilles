-- 1	Number of persons

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1 as analysis_id,  
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1
from @cdmDatabaseSchema.PERSON;

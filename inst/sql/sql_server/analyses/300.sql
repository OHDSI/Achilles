-- 300	Number of providers

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 300 as analysis_id,  
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct provider_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_300
from @cdmDatabaseSchema.provider;

-- 300	Number of providers


select 300 as analysis_id,  
cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(distinct provider_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_300
from @cdmDatabaseSchema.provider;

-- 301	Number of providers by specialty concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 301 as analysis_id,
CAST(specialty_concept_id AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct provider_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_301
from @cdmDatabaseSchema.provider
group by specialty_CONCEPT_ID;

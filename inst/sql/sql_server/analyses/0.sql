-- 0	cdm name, version of Achilles and date when pre-computations were executed

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 0 as analysis_id,  CAST('@source_name' AS VARCHAR(255)) as stratum_1, CAST('@achilles_version' AS VARCHAR(255)) as stratum_2, 
CAST(GETDATE() AS VARCHAR(255)) as stratum_3,
null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_0
from @cdmDatabaseSchema.PERSON;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 0 as analysis_id, CAST('@source_name' AS VARCHAR(255)) as stratum_1, 
null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(distinct person_id) as count_value, 
  null as min_value,
	null as max_value,
	null as avg_value,
	null as stdev_value,
	null as median_value,
	null as p10_value,
	null as p25_value,
	null as p75_value,
	null as p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_0
from @cdmDatabaseSchema.PERSON;

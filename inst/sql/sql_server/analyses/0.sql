-- 0	cdm name, version of Achilles and date when pre-computations were executed

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 0 as analysis_id,  CAST('@source_name' AS VARCHAR(255)) as stratum_1, CAST('@achilles_version' AS VARCHAR(255)) as stratum_2, 
CAST(GETDATE() AS VARCHAR(255)) as stratum_3,
cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(distinct person_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_0
from @cdmDatabaseSchema.person;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 0 as analysis_id, CAST('@source_name' AS VARCHAR(255)) as stratum_1, 
cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(distinct person_id) as count_value, 
  cast(null as float) as min_value,
	cast(null as float) as max_value,
	cast(null as float) as avg_value,
	cast(null as float) as stdev_value,
	cast(null as float) as median_value,
	cast(null as float) as p10_value,
	cast(null as float) as p25_value,
	cast(null as float) as p75_value,
	cast(null as float) as p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_0
from @cdmDatabaseSchema.person;

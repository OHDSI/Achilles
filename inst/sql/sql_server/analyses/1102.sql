-- 1102	Number of care sites by location 3-digit zip

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    left(l1.zip,3) as stratum_1,
    COUNT_BIG(distinct care_site_id) as count_value
  from @cdmDatabaseSchema.care_site cs1
    inner join @cdmDatabaseSchema.location l1
    on cs1.location_id = l1.location_id
  where cs1.location_id is not null
    and l1.zip is not null
  group by left(l1.zip,3)
)
SELECT
  1102 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1102
FROM rawData;

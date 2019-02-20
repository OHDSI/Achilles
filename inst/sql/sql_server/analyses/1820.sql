-- 1820	Number of observation records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(measurement_date)*100 + month(measurement_date) as stratum_1,
    COUNT_BIG(PERSON_ID) as count_value
  from @cdmDatabaseSchema.measurement m
  group by YEAR(measurement_date)*100 + month(measurement_date)
)
SELECT
  1820 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1820
FROM rawData;

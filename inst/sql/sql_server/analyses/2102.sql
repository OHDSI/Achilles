-- 2102	Number of persons by device by  start month, by device_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    m.device_CONCEPT_ID as stratum_1,
    YEAR(device_exposure_start_date)*100 + month(device_exposure_start_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
    @cdmDatabaseSchema.device_exposure m
  group by m.device_CONCEPT_ID,
    YEAR(device_exposure_start_date)*100 + month(device_exposure_start_date)
)
SELECT
  2102 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2102
FROM rawData;

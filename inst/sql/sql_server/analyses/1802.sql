-- 1802	Number of persons by measurement occurrence start month, by measurement_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    m.measurement_concept_id as stratum_1,
    YEAR(measurement_date)*100 + month(measurement_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
    @cdmDatabaseSchema.measurement m
  group by m.measurement_concept_id,
    YEAR(measurement_date)*100 + month(measurement_date)
)
SELECT
  1802 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1802
FROM rawData;
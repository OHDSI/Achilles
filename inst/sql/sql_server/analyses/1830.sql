-- 1830	Number of persons by measurement date year (YYYY), by measurement_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
    measurement_concept_id as stratum_1,
    YEAR(measurement_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  FROM
    @cdmDatabaseSchema.measurement
  GROUP BY measurement_concept_id,
    YEAR(measurement_date)
)
SELECT
  1830 as analysis_id,
  cast(stratum_1 as varchar(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1830
FROM rawData;
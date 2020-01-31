-- 502	Number of persons by death month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(death_date)*100 + month(death_date) as stratum_1,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.death d1
  group by YEAR(death_date)*100 + month(death_date)
)
SELECT
  502 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_502
FROM rawData;
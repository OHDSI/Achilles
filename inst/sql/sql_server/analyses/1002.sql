-- 1002	Number of persons by condition occurrence start month, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    ce1.condition_concept_id as stratum_1,
    YEAR(condition_era_start_date)*100 + month(condition_era_start_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.condition_era ce1
  group by ce1.condition_concept_id,
    YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
)
SELECT
  1002 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1002
FROM rawData;
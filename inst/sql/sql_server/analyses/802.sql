-- 802	Number of persons by observation occurrence start month, by observation_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    CAST(o1.observation_concept_id AS VARCHAR(255)) as stratum_1,
    YEAR(observation_date)*100 + month(observation_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.observation o1
  group by o1.observation_concept_id,
    YEAR(observation_date)*100 + month(observation_date)
)
SELECT
  802 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_802
FROM rawData;

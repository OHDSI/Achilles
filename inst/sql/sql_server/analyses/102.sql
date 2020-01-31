-- 102	Number of persons by gender by age, with age at first observation period

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    p1.gender_concept_id as stratum_1,
    year(op1.index_date) - p1.YEAR_OF_BIRTH as stratum_2,
    COUNT_BIG(p1.person_id) as count_value
  from @cdmDatabaseSchema.person p1
    inner join (select person_id, MIN(observation_period_start_date) as index_date from @cdmDatabaseSchema.observation_period group by PERSON_ID) op1
    on p1.PERSON_ID = op1.PERSON_ID
  group by p1.gender_concept_id, year(op1.index_date) - p1.YEAR_OF_BIRTH)
SELECT
  102 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_102
FROM rawData;

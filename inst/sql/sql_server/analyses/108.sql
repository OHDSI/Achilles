-- 108	Number of persons by length of observation period, in 30d increments

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30) as stratum_1,
    COUNT_BIG(distinct p1.person_id) as count_value
  from @cdmDatabaseSchema.person p1
    inner join
    (select person_id,
      OBSERVATION_PERIOD_START_DATE,
      OBSERVATION_PERIOD_END_DATE,
      ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
       from @cdmDatabaseSchema.observation_period
    ) op1
    on p1.PERSON_ID = op1.PERSON_ID
    where op1.rn1 = 1
  group by floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30)
)
SELECT
  108 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(null as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_108
FROM rawData;

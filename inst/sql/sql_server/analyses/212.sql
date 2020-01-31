-- 212	Number of persons with at least one visit occurrence by calendar year by gender by age decile

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    YEAR(visit_start_date) as stratum_1,
    p1.gender_concept_id as stratum_2,
    floor((year(visit_start_date) - p1.year_of_birth)/10) as stratum_3,
    COUNT_BIG(distinct p1.PERSON_ID) as count_value
  from @cdmDatabaseSchema.person p1
  inner join
  @cdmDatabaseSchema.visit_occurrence vo1
  on p1.person_id = vo1.person_id
  group by
    YEAR(visit_start_date),
    p1.gender_concept_id,
    floor((year(visit_start_date) - p1.year_of_birth)/10)
)
SELECT
  212 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(stratum_3 as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_212
FROM rawData;

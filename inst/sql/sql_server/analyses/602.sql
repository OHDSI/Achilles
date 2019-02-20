-- 602	Number of persons by procedure occurrence start month, by procedure_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    po1.procedure_concept_id as stratum_1,
    YEAR(procedure_date)*100 + month(procedure_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.procedure_occurrence po1
  group by po1.procedure_concept_id,
    YEAR(procedure_date)*100 + month(procedure_date)
)
SELECT
  602 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_602
FROM rawData;

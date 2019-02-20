-- 702	Number of persons by drug occurrence start month, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  select
    de1.drug_concept_id as stratum_1,
    YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  from
  @cdmDatabaseSchema.drug_exposure de1
  group by de1.drug_concept_id,
    YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date)
)
SELECT
  702 as analysis_id,
  CAST(stratum_1 AS VARCHAR(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_702
FROM rawData;

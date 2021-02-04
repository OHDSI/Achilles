-- 730	Number of persons by drug exposure start date year (YYYY), by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
  SELECT
    drug_concept_id as stratum_1,
    YEAR(drug_exposure_start_date) as stratum_2,
    COUNT_BIG(distinct PERSON_ID) as count_value
  FROM
  @cdmDatabaseSchema.drug_exposure
  GROUP BY drug_concept_id,
    YEAR(drug_exposure_start_date)
)
SELECT
  730 as analysis_id,
  cast(stratum_1 as varchar(255)) as stratum_1,
  cast(stratum_2 as varchar(255)) as stratum_2,
  cast(null as varchar(255)) as stratum_3,
  cast(null as varchar(255)) as stratum_4,
  cast(null as varchar(255)) as stratum_5,
  count_value
INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_730
FROM rawData;

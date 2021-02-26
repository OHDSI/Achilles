-- 702	Number of persons by drug occurrence start month, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	de.drug_concept_id AS stratum_1,
	YEAR(de.drug_exposure_start_date) * 100 + MONTH(de.drug_exposure_start_date) AS stratum_2,
	COUNT_BIG(DISTINCT de.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.drug_exposure de
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.drug_exposure_start_date >= op.observation_period_start_date
AND 
	de.drug_exposure_start_date <= op.observation_period_end_date
GROUP BY 
	de.drug_concept_id,
	YEAR(de.drug_exposure_start_date) * 100 + MONTH(de.drug_exposure_start_date)
)
SELECT
	702 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(stratum_2 AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_702
FROM 
	rawData;

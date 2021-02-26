-- 920	Number of drug era records by drug era start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
WITH rawData AS (
SELECT 
	YEAR(de.drug_era_start_date) * 100 + MONTH(de.drug_era_start_date) AS stratum_1,
	COUNT_BIG(de.person_id) AS count_value
FROM 
	@cdmDatabaseSchema.drug_era de
JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.drug_era_start_date >= op.observation_period_start_date
AND 
	de.drug_era_start_date <= op.observation_period_end_date
GROUP BY 
	YEAR(de.drug_era_start_date)*100 + MONTH(de.drug_era_start_date)
)
SELECT
	920 AS analysis_id,
	CAST(stratum_1 AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255)) AS stratum_2,
	CAST(NULL AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_920
FROM 
	rawData;

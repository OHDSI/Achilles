-- 1500 Total cost by drug_concept_id

SELECT
  1500 AS analysis_id,
  CAST(de.drug_concept_id AS VARCHAR(255)) AS stratum_1,
  CAST(c.cost_domain_id AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  SUM(c.total_charge) AS stratum_4,
  SUM(c.total_paid) AS stratum_5,
  SUM(c.total_cost) AS count_value
INTO 
  @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1500
FROM 
  @cdmDatabaseSchema.cost c
JOIN 
  @cdmDatabaseSchema.drug_exposure de
  ON c.cost_event_id = de.drug_exposure_id
WHERE 
  c.cost_domain_id = 'Drug'
  AND (
      c.total_cost IS NOT NULL OR
      c.total_charge IS NOT NULL OR
      c.total_paid IS NOT NULL
    )
GROUP BY 
  de.drug_concept_id, c.cost_domain_id
;
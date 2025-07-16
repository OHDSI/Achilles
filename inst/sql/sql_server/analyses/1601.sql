-- 1601 Total Cost by Procedure Domain by Month (Timeseries Report)

SELECT
  1601 AS analysis_id,
  CAST(c.cost_domain_id AS VARCHAR(255)) AS stratum_1,
  po.procedure_date AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  SUM(c.total_charge) as stratum_4,
  SUM(c.total_paid) as stratum_5,
  SUM(c.total_cost) AS count_value
INTO 
  @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1601
FROM 
  @cdmDatabaseSchema.cost c
JOIN 
  @cdmDatabaseSchema.procedure_occurrence po
  ON c.cost_event_id = po.procedure_occurrence_id
WHERE 
  c.cost_domain_id = 'Procedure'
  AND (
      c.total_cost IS NOT NULL OR
      c.total_charge IS NOT NULL OR
      c.total_paid IS NOT NULL
    )
GROUP BY 
  c.cost_domain_id, po.procedure_date
ORDER BY 
  stratum_2, stratum_1;
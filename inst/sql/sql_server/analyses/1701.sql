-- 1701 Total Cost by Visit Domain by Month (Timeseries Report)

SELECT
  1701 AS analysis_id,
  CAST(c.cost_domain_id AS VARCHAR(255)) AS stratum_1,
  vo.visit_start_date AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  SUM(c.total_charge) as stratum_4,
  SUM(c.total_paid) as stratum_5,
  SUM(c.total_cost) AS count_value
INTO 
  @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1701
FROM 
  @cdmDatabaseSchema.cost c
JOIN 
  @cdmDatabaseSchema.visit_occurrence vo
  ON c.cost_event_id = vo.visit_occurrence_id
WHERE 
  c.cost_domain_id = 'Visit'
  AND (
      c.total_cost IS NOT NULL OR
      c.total_charge IS NOT NULL OR
      c.total_paid IS NOT NULL
    )
GROUP BY 
  c.cost_domain_id, vo.visit_start_date
ORDER BY 
  stratum_2, stratum_1;
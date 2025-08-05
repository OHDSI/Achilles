-- 1700 Total cost by visit_concept_id

SELECT
  1700 AS analysis_id,
  CAST(visit_concept_id AS VARCHAR(255)) AS stratum_1,
  CAST(cost_domain_id AS VARCHAR(255)) AS stratum_2,
  CAST(NULL AS VARCHAR(255)) AS stratum_3,
  SUM(total_charge) AS stratum_4,
  SUM(total_paid) AS stratum_5,
  SUM(total_cost) AS count_value
INTO
  @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1700
FROM (
  -- Visit-level costs
  SELECT
    vo.visit_concept_id,
    'Visit' AS cost_domain_id,
    c.total_charge,
    c.total_paid,
    c.total_cost
  FROM @cdmDatabaseSchema.cost c
  JOIN @cdmDatabaseSchema.visit_occurrence vo
    ON c.cost_event_id = vo.visit_occurrence_id
  WHERE c.cost_domain_id = 'Visit'
    AND (
      c.total_cost IS NOT NULL OR
      c.total_charge IS NOT NULL OR
      c.total_paid IS NOT NULL
    )

  UNION ALL

  -- Visit Detail-level costs
  SELECT
    vo.visit_concept_id,
    'Visit Detail' AS cost_domain_id,
    c.total_charge,
    c.total_paid,
    c.total_cost
  FROM @cdmDatabaseSchema.cost c
  JOIN @cdmDatabaseSchema.visit_detail vd
    ON c.cost_event_id = vd.visit_detail_id
  JOIN @cdmDatabaseSchema.visit_occurrence vo
    ON vd.visit_occurrence_id = vo.visit_occurrence_id
  WHERE c.cost_domain_id = 'Visit Detail'
    AND (
      c.total_cost IS NOT NULL OR
      c.total_charge IS NOT NULL OR
      c.total_paid IS NOT NULL
    )
) AS combined
GROUP BY visit_concept_id, cost_domain_id;

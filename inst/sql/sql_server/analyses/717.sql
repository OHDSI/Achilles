-- 717	Distribution of quantity by drug_concept_id

-- Compute concept-level aggregations
DROP TABLE IF EXISTS #tempAgg_717;
--HINT DISTRIBUTE_ON_KEY(drug_concept_id)
  SELECT o.drug_concept_id
    , COUNT_BIG(*) AS num_recs
    , MIN(o.quantity) AS min_value
    , MAX(o.quantity) AS max_value
    , CAST(AVG(1.0 * o.quantity) AS FLOAT) AS avg_value
    , CAST(STDDEV(o.quantity) AS FLOAT) AS stdev_value
  INTO #tempAgg_717
  FROM 
    @cdmDatabaseSchema.drug_exposure o
  JOIN 
    @cdmDatabaseSchema.observation_period op 
  ON 
    o.person_id = op.person_id
  AND 
    o.drug_exposure_start_date >= op.observation_period_start_date
  AND 
    o.drug_exposure_start_date <= op.observation_period_end_date
  WHERE 
    o.quantity IS NOT NULL
  GROUP BY o.drug_concept_id
;

-- Compute concept+quantity-level aggregations
DROP TABLE IF EXISTS #tempByval_717;
--HINT DISTRIBUTE_ON_KEY(drug_concept_id)
  SELECT 
    o.drug_concept_id
    , o.quantity
    , COUNT_BIG(*) AS num_recs
  INTO #tempByval_717
  FROM 
    @cdmDatabaseSchema.drug_exposure o
  JOIN 
    @cdmDatabaseSchema.observation_period op 
  ON 
    o.person_id = op.person_id
  AND 
    o.drug_exposure_start_date >= op.observation_period_start_date
  AND 
    o.drug_exposure_start_date <= op.observation_period_end_date
  WHERE 
    o.quantity IS NOT NULL
  GROUP BY o.drug_concept_id
    , o.quantity
;

-- Get cumulative # of rows BY ordered values (needed to determine quartiles & deciles)
DROP TABLE IF EXISTS #tempOrdbyval_717;
--HINT DISTRIBUTE_ON_KEY(drug_concept_id)
  SELECT drug_concept_id
    , quantity
    , num_recs
    , SUM(num_recs) OVER (PARTITION BY drug_concept_id ORDER BY quantity) AS cum_num_recs
  INTO #tempOrdbyval_717
  FROM #tempByval_717
;

-- Determine record-count cutpoints - cumulative # of records needed for quartiles & deciles
DROP TABLE IF EXISTS #tempCutpoints_717;
--HINT DISTRIBUTE_ON_KEY(drug_concept_id)
  SELECT drug_concept_id
    , FLOOR(num_recs * 0.10) AS pct10_cutpoint
    , FLOOR(num_recs * 0.25) AS pct25_cutpoint
    , FLOOR(num_recs * 0.50) AS pct50_cutpoint
    , FLOOR(num_recs * 0.75) AS pct75_cutpoint
    , FLOOR(num_recs * 0.90) AS pct90_cutpoint
  INTO #tempCutpoints_717
  FROM #tempAgg_717
;

-- Compute quartiles & deciles (plus median) based upon those cutpoints
DROP TABLE IF EXISTS #tempCalc_717;
--HINT DISTRIBUTE_ON_KEY(drug_concept_id)
  SELECT ct.drug_concept_id
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct10_cutpoint THEN ov.quantity ELSE NULL END) AS p10_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct25_cutpoint THEN ov.quantity ELSE NULL END) AS p25_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct50_cutpoint THEN ov.quantity ELSE NULL END) AS median_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct75_cutpoint THEN ov.quantity ELSE NULL END) AS p75_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct90_cutpoint THEN ov.quantity ELSE NULL END) AS p90_value
  INTO  #tempCalc_717
  FROM #tempOrdbyval_717 ov
  JOIN #tempCutpoints_717 ct
    ON ov.drug_concept_id = ct.drug_concept_id
  GROUP BY ct.drug_concept_id
;

-- Select final values for inclusion INTO achilles_results_dist
-- HINT DISTRIBUTE_ON_RANDOM 
SELECT 717 AS analysis_id
  , a.drug_concept_id AS stratum_1
  , a.num_recs AS count_value
  , a.min_value
  , a.max_value
  , a.avg_value
  , a.stdev_value
  , CASE WHEN c.median_value IS NULL THEN a.max_value ELSE c.median_value END as median_value
  , CASE WHEN c.p10_value IS NULL THEN a.max_value ELSE c.p10_value END as p10_value
  , CASE WHEN c.p25_value IS NULL THEN a.max_value ELSE c.p25_value END  as p25_value
  , CASE WHEN c.p75_value IS NULL THEN a.max_value ELSE c.p75_value END  as p75_value
  , CASE WHEN c.p90_value IS NULL THEN a.max_value ELSE c.p90_value END  as p90_value
INTO #tempResults_717
FROM #tempAgg_717 a
JOIN #tempCalc_717 c
  ON a.drug_concept_id = c.drug_concept_id
ORDER BY a.drug_concept_id
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, stratum_1, cast(null as varchar(255)) as stratum_2, 
cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_717
from #tempResults_717
;

truncate table #tempResults_717;
drop table #tempResults_717;

truncate table #tempAgg_717;
drop table #tempAgg_717;

truncate table #tempByval_717;
drop table #tempByval_717;

truncate table #tempOrdbyval_717;
drop table #tempOrdbyval_717;

truncate table #tempCutpoints_717;
drop table #tempCutpoints_717;

truncate table #tempCalc_717;
drop table #tempCalc_717;
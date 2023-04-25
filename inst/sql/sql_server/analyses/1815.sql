-- 1815  Distribution of numeric values, by measurement_concept_id and unit_concept_id

-- Compute concept+unit-level aggregations
DROP TABLE IF EXISTS #tempAgg_1815;
--HINT DISTRIBUTE_ON_KEY(measurement_concept_id)
  SELECT o.measurement_concept_id
    , o.unit_concept_id
    , COUNT_BIG(*) AS num_recs
    , MIN(o.value_as_number) AS min_value
    , MAX(o.value_as_number) AS max_value
    , CAST(AVG(1.0 * o.value_as_number) AS FLOAT) AS avg_value
    , CAST(STDDEV(o.value_as_number) AS FLOAT) AS stdev_value
  INTO #tempAgg_1815
  FROM 
    @cdmDatabaseSchema.measurement o
  JOIN 
    @cdmDatabaseSchema.observation_period op 
  ON 
    o.person_id = op.person_id
  AND 
    o.measurement_date >= op.observation_period_start_date
  AND 
    o.measurement_date <= op.observation_period_end_date
  WHERE 
    o.unit_concept_id IS NOT NULL
  AND 
    o.value_as_number IS NOT NULL
  GROUP BY o.measurement_concept_id
    , o.unit_concept_id
;

-- Compute concept+unit+value-level aggregations
DROP TABLE IF EXISTS #tempByval_1815;
--HINT DISTRIBUTE_ON_KEY(measurement_concept_id)
  SELECT 
    o.measurement_concept_id
    , o.unit_concept_id
    , o.value_as_number
    , COUNT_BIG(*) AS num_recs
  INTO #tempByval_1815
  FROM 
    @cdmDatabaseSchema.measurement o
  JOIN 
    @cdmDatabaseSchema.observation_period op 
  ON 
    o.person_id = op.person_id
  AND 
    o.measurement_date >= op.observation_period_start_date
  AND 
    o.measurement_date <= op.observation_period_end_date
  WHERE 
    o.unit_concept_id IS NOT NULL
  AND 
    o.value_as_number IS NOT NULL
  GROUP BY o.measurement_concept_id
    , o.unit_concept_id
    , o.value_as_number
;

-- Get cumulative # of rows BY ordered values (needed to determine quartiles & deciles)
DROP TABLE IF EXISTS #tempOrdbyval_1815;
--HINT DISTRIBUTE_ON_KEY(measurement_concept_id)
  SELECT measurement_concept_id
    , unit_concept_id
    , value_as_number
    , num_recs
    , SUM(num_recs) OVER (PARTITION BY measurement_concept_id, unit_concept_id ORDER BY value_as_number) AS cum_num_recs
  INTO #tempOrdbyval_1815
  FROM #tempByval_1815
;

-- Determine record-count cutpoints - cumulative # of records needed for quartiles & deciles
DROP TABLE IF EXISTS #tempCutpoints_1815;
--HINT DISTRIBUTE_ON_KEY(measurement_concept_id)
  SELECT measurement_concept_id
    , unit_concept_id
    , FLOOR(num_recs * 0.10) AS pct10_cutpoint
    , FLOOR(num_recs * 0.25) AS pct25_cutpoint
    , FLOOR(num_recs * 0.50) AS pct50_cutpoint
    , FLOOR(num_recs * 0.75) AS pct75_cutpoint
    , FLOOR(num_recs * 0.90) AS pct90_cutpoint
  INTO #tempCutpoints_1815
  FROM #tempAgg_1815
;

-- Compute quartiles & deciles (plus median) based upon those cutpoints
DROP TABLE IF EXISTS #tempCalc_1815;
--HINT DISTRIBUTE_ON_KEY(measurement_concept_id)
  SELECT ct.measurement_concept_id
    , ct.unit_concept_id
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct10_cutpoint THEN ov.value_as_number ELSE NULL END) AS p10_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct25_cutpoint THEN ov.value_as_number ELSE NULL END) AS p25_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct50_cutpoint THEN ov.value_as_number ELSE NULL END) AS median_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct75_cutpoint THEN ov.value_as_number ELSE NULL END) AS p75_value
    , MIN(CASE WHEN ov.cum_num_recs >= ct.pct90_cutpoint THEN ov.value_as_number ELSE NULL END) AS p90_value
  INTO  #tempCalc_1815
  FROM #tempOrdbyval_1815 ov
  JOIN #tempCutpoints_1815 ct
    ON ov.measurement_concept_id = ct.measurement_concept_id
      AND ov.unit_concept_id = ct.unit_concept_id
  GROUP BY ct.measurement_concept_id
    , ct.unit_concept_id
;

-- Select final values for inclusion INTO achilles_results_dist
-- HINT DISTRIBUTE_ON_RANDOM 
SELECT 1815 AS analysis_id
  , a.measurement_concept_id AS stratum_1
  , a.unit_concept_id AS stratum_2
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
INTO #tempResults_1815
FROM #tempAgg_1815 a
JOIN #tempCalc_1815 c
  ON a.measurement_concept_id = c.measurement_concept_id
  AND a.unit_concept_id = c.unit_concept_id
ORDER BY a.measurement_concept_id
  , a.unit_concept_id
;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select analysis_id, stratum_1, stratum_2, 
cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_dist_1815
from #tempResults_1815
;

truncate table #tempResults_1815;
drop table #tempResults_1815;

truncate table #tempAgg_1815;
drop table #tempAgg_1815;

truncate table #tempByval_1815;
drop table #tempByval_1815;

truncate table #tempOrdbyval_1815;
drop table #tempOrdbyval_1815;

truncate table #tempCutpoints_1815;
drop table #tempCutpoints_1815;

truncate table #tempCalc_1815;
drop table #tempCalc_1815;
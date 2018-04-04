--ruleid 23 WARNING:  monthly change > 100% at concept level

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  SELECT ar1.analysis_id,
  	CAST(CONCAT('WARNING: ', cast(ar1.analysis_id as VARCHAR), '-', aa1.analysis_name, '; ', cast(COUNT_BIG(DISTINCT ar1.stratum_1) AS VARCHAR), ' concepts have a 100% change in monthly count of events') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    23 as rule_id,
    COUNT_BIG(DISTINCT ar1.stratum_1) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_analysis aa1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_results ar1
  	ON aa1.analysis_id = ar1.analysis_id
  INNER JOIN @resultsDatabaseSchema.ACHILLES_results ar2
  	ON ar1.analysis_id = ar2.analysis_id
  		AND ar1.stratum_1 = ar2.stratum_1
  		AND ar1.analysis_id IN (
  			402,
  			602,
  			702,
  			802,
  			902,
  			1002
  			)
  WHERE (
  		ROUND(CAST(ar1.stratum_2 AS DECIMAL(18,4)),0) + 1 = ROUND(CAST(ar2.stratum_2 AS DECIMAL(18,4)),0)
		OR ROUND(CAST(ar1.stratum_2 AS DECIMAL(18,4)),0) + 89 = ROUND(CAST(ar2.stratum_2 AS DECIMAL(18,4)),0)
  		)
  	AND 1.0 * abs(ar2.count_value - ar1.count_value) / ar1.count_value > 1
  	AND ar1.count_value > 10
  GROUP BY ar1.analysis_id,
  	aa1.analysis_name
) A;

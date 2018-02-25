--ruleid 22 WARNING:  monthly change > 100%

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	null as record_count
	into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  SELECT DISTINCT ar1.analysis_id,
  	CAST(CONCAT('WARNING: ', cast(ar1.analysis_id as VARCHAR), '-', aa1.analysis_name, '; theres a 100% change in monthly count of events') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    22 as rule_id
    
  FROM @resultsDatabaseSchema.ACHILLES_analysis aa1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_results ar1
  	ON aa1.analysis_id = ar1.analysis_id
  INNER JOIN @resultsDatabaseSchema.ACHILLES_results ar2
  	ON ar1.analysis_id = ar2.analysis_id
  		AND ar1.analysis_id IN (
  			420,
  			620,
  			720,
  			820,
  			920,
  			1020
  			)
  WHERE (
  		CAST(ar1.stratum_1 AS INT) + 1 = CAST(ar2.stratum_1 AS INT)
  		OR CAST(ar1.stratum_1 AS INT) + 89 = CAST(ar2.stratum_1 AS INT)
  		)
  	AND 1.0 * abs(ar2.count_value - ar1.count_value) / ar1.count_value > 1
  	AND ar1.count_value > 10
) A;

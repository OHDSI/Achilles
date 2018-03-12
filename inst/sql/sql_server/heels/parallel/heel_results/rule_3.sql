--ruleid 3 death distributions where max should not be positive

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
  into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  SELECT DISTINCT ord1.analysis_id,
    CAST(CONCAT('WARNING: ', cast(ord1.analysis_id as VARCHAR), '-', oa1.analysis_name, ' (count = ', cast(COUNT_BIG(ord1.max_value) as VARCHAR), '); max value should not be positive, otherwise its a zombie with data >1mo after death ') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    3 as rule_id,
    COUNT_BIG(ord1.max_value) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results_dist ord1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON ord1.analysis_id = oa1.analysis_id
  WHERE ord1.analysis_id IN (
  		511,
  		512,
  		513,
  		514,
  		515
  		)
  	AND ord1.max_value > 30
  GROUP BY ord1.analysis_id, oa1.analysis_name
) A;

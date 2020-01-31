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
    CAST(CONCAT('WARNING: ', cast(ord1.analysis_id as VARCHAR(10)), '-', oa1.analysis_name, ' (count = ', cast(ord1.record_count as VARCHAR(19)), '); max value should not be positive, otherwise its a zombie with data >1mo after death ') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    3 as rule_id,
    ord1.record_count
  FROM @resultsDatabaseSchema.ACHILLES_analysis oa1
		INNER JOIN (SELECT analysis_id, COUNT_BIG(max_value) AS record_count FROM @resultsDatabaseSchema.achilles_results_dist
  	WHERE analysis_id IN (
  		511,
  		512,
  		513,
  		514,
  		515
  		)
  	AND max_value > 60
  	GROUP BY analysis_id) ord1 ON ord1.analysis_id = oa1.analysis_id
) A;

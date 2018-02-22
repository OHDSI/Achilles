--ruleid 26 DQ rule: WARNING: quantity > 600

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
    'WARNING: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(count(ord1.max_value) as VARCHAR) + '); max value should not be > 600' AS ACHILLES_HEEL_warning,
    26 as rule_id,
    count(ord1.max_value) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results_dist ord1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON ord1.analysis_id = oa1.analysis_id
  WHERE ord1.analysis_id IN (717)
  	AND ord1.max_value > 600
  GROUP BY ord1.analysis_id, oa1.analysis_name
) A;

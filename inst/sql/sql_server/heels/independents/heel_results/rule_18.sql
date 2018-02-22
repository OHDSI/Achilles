--ruleid 18 ERROR:  year of birth in the future

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
	into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  SELECT DISTINCT or1.analysis_id,
  	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have year of birth in the future, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning,
    18 as rule_id,
    sum(or1.count_value) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
  WHERE or1.analysis_id IN (3)
  	AND CAST(or1.stratum_1 AS INT) > year(getdate())
  	AND or1.count_value > 0
  GROUP BY or1.analysis_id,
    oa1.analysis_name
) A;

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
  	CAST(CONCAT('ERROR: ', cast(or1.analysis_id as VARCHAR(10)), '-', oa1.analysis_name, '; should not have year of birth in the future, (n=', cast(or1.record_count as VARCHAR(19)), ')') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    18 as rule_id,
    or1.record_count
  FROM @resultsDatabaseSchema.ACHILLES_analysis oa1
  INNER JOIN (
      SELECT analysis_id, SUM(count_value) AS record_count FROM @resultsDatabaseSchema.achilles_results
      WHERE analysis_id IN (3)
            AND CAST(stratum_1 AS INT) > year(getdate())
            AND count_value > 0
      GROUP BY analysis_id
      ) or1
  	ON or1.analysis_id = oa1.analysis_id
) A;

--ruleid 8 race  - 13 CDC Race

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
  into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
from
(
  SELECT or1.analysis_id,
  	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning,
    8 as rule_id,
    COUNT_BIG(DISTINCT stratum_1) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
  INNER JOIN @cdmDatabaseSchema.concept c1
  	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
  WHERE or1.analysis_id IN (4)
  	AND or1.stratum_1 IS NOT NULL
  	AND c1.concept_id <> 0 
    AND lower(c1.domain_id) NOT IN ('race')
  GROUP BY or1.analysis_id,
  	oa1.analysis_name
) A;

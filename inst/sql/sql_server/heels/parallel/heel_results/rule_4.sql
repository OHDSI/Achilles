--ruleid 4 CDM-conformance rule: invalid concept_id

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
  	CAST(CONCAT('ERROR: ', cast(or1.analysis_id as VARCHAR), '-', oa1.analysis_name, '; ', cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR), ' concepts in data are not in vocabulary') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    4 as rule_id,
    COUNT_BIG(DISTINCT stratum_1) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
  LEFT JOIN @cdmDatabaseSchema.concept c1
  	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR(19))
  WHERE or1.analysis_id IN (
  		2,
  		4,
  		5,
  		200,
  		301,
  		400,
  		500,
  		505,
  		600,
  		700,
  		800,
  		900,
  		1000,
  		1609,
  		1610
  		)
  	AND or1.stratum_1 IS NOT NULL
  	AND c1.concept_id IS NULL
  GROUP BY or1.analysis_id,
  	oa1.analysis_name
) A;

--ruleid 6 CDM-conformance rule:invalid concept_id

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
  	'WARNING: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; data with unmapped concepts' AS ACHILLES_HEEL_warning,
    6 as rule_id,
    null as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
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
  	AND or1.stratum_1 = '0'
  GROUP BY or1.analysis_id,
  	oa1.analysis_name
) A;

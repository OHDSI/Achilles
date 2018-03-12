--ruleid 5 CDM-conformance rule:invalid type concept_id
--this rule is only checking that the concept is valid (joins to concept table at all)
--it does not check the vocabulary_id to further restrict the scope of the valid concepts
--to only include,for example, death types 

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
  	CAST(CONCAT('ERROR: ', cast(or1.analysis_id as VARCHAR), '-', oa1.analysis_name, '; ', cast(COUNT_BIG(DISTINCT stratum_2) AS VARCHAR), ' concepts in data are not in vocabulary') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    5 as rule_id,
    COUNT_BIG(DISTINCT stratum_2) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
  LEFT JOIN @cdmDatabaseSchema.concept c1
  	ON or1.stratum_2 = CAST(c1.concept_id AS VARCHAR(19))
  WHERE or1.analysis_id IN (
  		405,
  		605,
  		705,
  		805,
  		1805
  		)
  	AND or1.stratum_2 IS NOT NULL
  	AND c1.concept_id IS NULL
  GROUP BY or1.analysis_id,
  	oa1.analysis_name
) A;

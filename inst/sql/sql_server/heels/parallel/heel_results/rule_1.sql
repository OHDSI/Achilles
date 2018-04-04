--Some rules check conformance to the CDM model, other rules look at data quality


--ruleid 1 check for non-zero counts from checks of improper data (invalid ids, out-of-bound data, inconsistent dates)

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
  	CAST(CONCAT('ERROR: ', cast(or1.analysis_id as VARCHAR), '-', oa1.analysis_name, '; count (n=', cast(or1.count_value as VARCHAR), ') should not be > 0') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
  	1 as rule_id,
  	or1.count_value as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
  WHERE or1.analysis_id IN (
  		7,
  		8,
  		9,
  		114,
  		115,
  		118,
  		207,
  		208,
  		209,
  		210,
  		302,
  		409,
  		410,
  		411,
  		412,
  		413,
  		509,
  		--510, taken out from this umbrella rule and implemented separately
  		609,
  		610,
  		612,
  		613,
  		709,
  		710,
  		711,
  		712,
  		713,
  		809,
  		810,
  		812,
  		813,
  		814,
  		908,
  		909,
  		910,
  		1008,
  		1009,
  		1010,
  		1415,
  		1500,
  		1501,
  		1600,
  		1601,
  		1701
  		) --all explicit counts of data anamolies
  	AND or1.count_value > 0
  ) A;

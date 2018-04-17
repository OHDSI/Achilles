--ruleid 2 distributions where min should not be negative

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 
	analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
	into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName
	from
	(
    SELECT ord1.analysis_id,
    CAST(CONCAT('ERROR: ', cast(ord1.analysis_id as VARCHAR), ' - ', oa1.analysis_name, ' (count = ', cast(COUNT_BIG(ord1.min_value) as VARCHAR), '); min value should not be negative') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    2 as rule_id,
    COUNT_BIG(ord1.min_value) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results_dist ord1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON ord1.analysis_id = oa1.analysis_id
  WHERE ord1.analysis_id IN (
  		103,
  		105,
  		206,
  		406,
  		506,
  		606,
  		706,
  		715,
  		716,
  		717,
  		806,
  		906,
  		907,
  		1006,
  		1007,
  		1502,
  		1503,
  		1504,
  		1505,
  		1506,
  		1507,
  		1508,
  		1509,
  		1510,
  		1511,
  		1602,
  		1603,
  		1604,
  		1605,
  		1606,
  		1607,
  		1608
  		)
  	AND ord1.min_value < 0
  	GROUP BY ord1.analysis_id,  oa1.analysis_name
) A;

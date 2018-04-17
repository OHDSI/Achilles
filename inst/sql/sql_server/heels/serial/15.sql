--ruleid 36 WARNING: age > 125   (related to an error grade rule 21 that has higher threshold)
select *
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrNewId
from
(
  select * from @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_hr_@hrOldId
  
  union all
  
  SELECT or1.analysis_id,
  	CAST(CONCAT('WARNING: ', cast(or1.analysis_id as VARCHAR), '-', oa1.analysis_name, '; should not have age > @ThresholdAgeWarning, (n=', cast(sum(or1.count_value) as VARCHAR), ')') AS VARCHAR(255)) AS ACHILLES_HEEL_warning,
    36 as rule_id,
    sum(or1.count_value) as record_count
  FROM @resultsDatabaseSchema.ACHILLES_results or1
  INNER JOIN @resultsDatabaseSchema.ACHILLES_analysis oa1
  	ON or1.analysis_id = oa1.analysis_id
  WHERE or1.analysis_id IN (101)
  	AND CAST(or1.stratum_1 AS INT) > @ThresholdAgeWarning
  	AND or1.count_value > 0
  GROUP BY or1.analysis_id,
    oa1.analysis_name
) Q
;
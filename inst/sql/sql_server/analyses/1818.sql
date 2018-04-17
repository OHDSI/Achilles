-- 1818	Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id


--HINT DISTRIBUTE_ON_KEY(person_id)
select 
  person_id,
  measurement_concept_id,
  unit_concept_id,
  CAST(case when value_as_number < range_low then 'Below Range Low'
  		when value_as_number >= range_low and value_as_number <= range_high then 'Within Range'
  		when value_as_number > range_high then 'Above Range High'
  		else 'Other' end AS VARCHAR(255)) as stratum_3
  into #rawData_1818
  from @cdmDatabaseSchema.measurement
  where value_as_number is not null
    and unit_concept_id is not null
    and range_low is not null
    and range_high is not null;

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1818 as analysis_id,  
	CAST(measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(unit_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(stratum_3 AS VARCHAR(255)) as stratum_3,
	null as stratum_4, 
	null as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1818
from #rawData_1818
group by measurement_concept_id,
	unit_concept_id,
  stratum_3
;

truncate table #rawData_1818;
drop table #rawData_1818;


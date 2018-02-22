-- 1818	Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1818 as analysis_id,  
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(m.unit_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(case when m.value_as_number < m.range_low then 'Below Range Low'
		when m.value_as_number >= m.range_low and m.value_as_number <= m.range_high then 'Within Range'
		when m.value_as_number > m.range_high then 'Above Range High'
		else 'Other' end AS VARCHAR(255)) as stratum_3,
		null as stratum_4, null as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1818
from @cdmDatabaseSchema.measurement m
where m.value_as_number is not null
	and m.unit_concept_id is not null
	and m.range_low is not null
	and m.range_high is not null
group by measurement_concept_id,
	unit_concept_id,
	  CAST(case when m.value_as_number < m.range_low then 'Below Range Low'
		when m.value_as_number >= m.range_low and m.value_as_number <= m.range_high then 'Within Range'
		when m.value_as_number > m.range_high then 'Above Range High'
		else 'Other' end AS VARCHAR(255))
;

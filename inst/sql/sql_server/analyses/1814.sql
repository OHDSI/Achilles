-- 1814	Number of measurement records with no value (numeric or concept)

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1814 as analysis_id,
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1814
from
	@cdmDatabaseSchema.measurement m
where m.value_as_number is null
	and m.value_as_concept_id is null
;

-- 1814	Number of measurement records with no value (numeric or concept)


select 1814 as analysis_id,
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1814
from
	@cdmDatabaseSchema.measurement m
where m.value_as_number is null
	and m.value_as_concept_id is null
;

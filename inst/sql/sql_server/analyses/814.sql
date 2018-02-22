-- 814	Number of observation records with no value (numeric, string, or concept)

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 814 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(o1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_814
from
	@cdmDatabaseSchema.observation o1
where o1.value_as_number is null
	and o1.value_as_string is null
	and o1.value_as_concept_id is null
;

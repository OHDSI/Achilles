--207	Number of visit records with invalid person_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 207 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(vo1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_207
from
	@cdmDatabaseSchema.visit_occurrence vo1
	left join @cdmDatabaseSchema.PERSON p1
	on p1.person_id = vo1.person_id
where p1.person_id is null
;

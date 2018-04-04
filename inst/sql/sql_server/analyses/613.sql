-- 613	Number of procedure occurrence records with invalid visit_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 613 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(po1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_613
from
	@cdmDatabaseSchema.procedure_occurrence po1
	left join @cdmDatabaseSchema.visit_occurrence vo1
	on po1.visit_occurrence_id = vo1.visit_occurrence_id
where po1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;

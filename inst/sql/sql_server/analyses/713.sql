-- 713	Number of drug exposure records with invalid visit_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 713 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_713
from
	@cdmDatabaseSchema.drug_exposure de1
	left join @cdmDatabaseSchema.visit_occurrence vo1
	on de1.visit_occurrence_id = vo1.visit_occurrence_id
where de1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;

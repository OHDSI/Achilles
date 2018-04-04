--209	Number of visit records with end date < start date

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 209 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(vo1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_209
from
	@cdmDatabaseSchema.visit_occurrence vo1
where visit_end_date < visit_start_date
;

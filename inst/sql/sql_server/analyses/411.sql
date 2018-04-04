-- 411	Number of condition occurrence records with end date < start date

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 411 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(co1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_411
from
	@cdmDatabaseSchema.condition_occurrence co1
where co1.condition_end_date < co1.condition_start_date
;

-- 1010	Number of condition eras with end date < start date


select 1010 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(ce1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1010
from
	@cdmDatabaseSchema.condition_era ce1
where ce1.condition_era_end_date < ce1.condition_era_start_date
;

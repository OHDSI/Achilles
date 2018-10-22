-- 411	Number of condition occurrence records with end date < start date


select 411 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(co1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_411
from
	@cdmDatabaseSchema.condition_occurrence co1
where co1.condition_end_date < co1.condition_start_date
;

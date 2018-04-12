-- 1701	Number of records with cohort end date < cohort start date


select 1701 as analysis_id, 
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(subject_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1701
from
	@resultsDatabaseSchema.cohort c1
where c1.cohort_end_date < c1.cohort_start_date
;

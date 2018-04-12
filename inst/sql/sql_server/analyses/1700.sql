-- 1700	Number of records by cohort_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1700 as analysis_id, 
	CAST(cohort_definition_id AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(subject_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1700
from
	@resultsDatabaseSchema.cohort c1
group by cohort_definition_id
;

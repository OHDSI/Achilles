-- 908	Number of drug eras with invalid person

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 908 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_908
from
	@cdmDatabaseSchema.drug_era de1
	left join @cdmDatabaseSchema.PERSON p1
	on p1.person_id = de1.person_id
where p1.person_id is null
;

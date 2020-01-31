-- 709	Number of drug exposure records with invalid person_id


select 709 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_709
from
	@cdmDatabaseSchema.drug_exposure de1
	left join @cdmDatabaseSchema.person p1
	on p1.person_id = de1.person_id
where p1.person_id is null
;

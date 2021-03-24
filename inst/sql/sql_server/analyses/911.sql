-- 911	Number of drug eras with end date < start date


select 911 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_911
from
	@cdmDatabaseSchema.drug_era de1
where de1.drug_era_end_date < de1.drug_era_start_date
;

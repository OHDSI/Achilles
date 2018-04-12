-- 910	Number of drug eras with end date < start date


select 910 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_910
from
	@cdmDatabaseSchema.drug_era de1
where de1.drug_era_end_date < de1.drug_era_start_date
;

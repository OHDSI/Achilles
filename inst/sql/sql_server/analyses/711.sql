-- 711	Number of drug exposure records with end date < start date


select 711 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_711
from
	@cdmDatabaseSchema.drug_exposure de1
where de1.drug_exposure_end_date < de1.drug_exposure_start_date
;

-- 720	Number of drug exposure records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 720 as analysis_id,   
	CAST(YEAR(drug_exposure_start_datetime)*100 + month(drug_exposure_start_datetime) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_720
from
@cdmDatabaseSchema.drug_exposure de1
group by YEAR(drug_exposure_start_datetime)*100 + month(drug_exposure_start_datetime)
;

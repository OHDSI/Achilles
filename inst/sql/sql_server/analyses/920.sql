-- 920	Number of drug era records by drug era start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 920 as analysis_id,   
	CAST(YEAR(drug_era_start_date)*100 + month(drug_era_start_date) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_920
from
@cdmDatabaseSchema.drug_era de1
group by YEAR(drug_era_start_date)*100 + month(drug_era_start_date)
;

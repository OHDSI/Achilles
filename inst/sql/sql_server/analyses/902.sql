-- 902	Number of persons by drug occurrence start month, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 902 as analysis_id,   
	CAST(de1.drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(drug_era_start_date)*100 + month(drug_era_start_date) AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_902
from
@cdmDatabaseSchema.drug_era de1
group by de1.drug_concept_id, 
	YEAR(drug_era_start_date)*100 + month(drug_era_start_date)
;

-- 701	Number of drug occurrence records, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 701 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_701
from
	@cdmDatabaseSchema.drug_exposure de1
group by de1.drug_CONCEPT_ID
;

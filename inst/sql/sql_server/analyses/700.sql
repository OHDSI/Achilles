-- 700	Number of persons with at least one drug occurrence, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 700 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_700
from
	@cdmDatabaseSchema.drug_exposure de1
group by de1.drug_CONCEPT_ID
;

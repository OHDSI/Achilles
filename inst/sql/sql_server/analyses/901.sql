-- 901	Number of drug occurrence records, by drug_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 901 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(de1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_901
from
	@cdmDatabaseSchema.drug_era de1
group by de1.drug_CONCEPT_ID
;

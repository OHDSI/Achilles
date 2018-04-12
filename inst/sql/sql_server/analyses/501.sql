-- 501	Number of records of death, by cause_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 501 as analysis_id, 
	CAST(d1.cause_concept_id AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(d1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_501
from
	@cdmDatabaseSchema.death d1
group by d1.cause_concept_id
;

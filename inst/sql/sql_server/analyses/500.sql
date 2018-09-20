-- 500	Number of persons with death, by cause_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 500 as analysis_id, 
	CAST(d1.cause_concept_id AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct d1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_500
from
	@cdmDatabaseSchema.death d1
group by d1.cause_concept_id
;

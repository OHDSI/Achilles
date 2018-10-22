-- 400	Number of persons with at least one condition occurrence, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 400 as analysis_id, 
	CAST(co1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct co1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_400
from
	@cdmDatabaseSchema.condition_occurrence co1
group by co1.condition_CONCEPT_ID
;

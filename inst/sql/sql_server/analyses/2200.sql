-- 2200	Number of persons with at least one note , by note_type_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 2200 as analysis_id, 
	CAST(m.note_type_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2200
from
	@cdmDatabaseSchema.note m
group by m.note_type_CONCEPT_ID
;

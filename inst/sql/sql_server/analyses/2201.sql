-- 2201	Number of device exposure  records, by device_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 2201 as analysis_id, 
    CAST(m.note_type_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2201
from
	@cdmDatabaseSchema.note m
group by m.note_type_CONCEPT_ID
;

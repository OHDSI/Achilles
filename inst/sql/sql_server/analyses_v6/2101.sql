-- 2101	Number of device exposure  records, by device_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 2101 as analysis_id, 
    CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2101
from
	@cdmDatabaseSchema.device_exposure m
group by m.device_CONCEPT_ID
;

-- 1813	Number of observation records with invalid visit_id


select 1813 as analysis_id, 
cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1813
from @cdmDatabaseSchema.measurement m
	left join @cdmDatabaseSchema.visit_occurrence vo on m.visit_occurrence_id = vo.visit_occurrence_id
where m.visit_occurrence_id is not null
	and vo.visit_occurrence_id is null
;

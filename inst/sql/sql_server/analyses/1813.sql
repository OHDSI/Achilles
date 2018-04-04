-- 1813	Number of observation records with invalid visit_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1813 as analysis_id, 
null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
COUNT_BIG(m.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1813
from @cdmDatabaseSchema.measurement m
	left join @cdmDatabaseSchema.visit_occurrence vo on m.visit_occurrence_id = vo.visit_occurrence_id
where m.visit_occurrence_id is not null
	and vo.visit_occurrence_id is null
;

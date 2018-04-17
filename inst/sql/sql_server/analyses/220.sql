-- 220	Number of visit occurrence records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 220 as analysis_id,   
	CAST(YEAR(visit_start_date)*100 + month(visit_start_date) AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_220
from
@cdmDatabaseSchema.visit_occurrence vo1
group by YEAR(visit_start_date)*100 + month(visit_start_date)
;

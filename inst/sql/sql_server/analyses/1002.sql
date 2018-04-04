-- 1002	Number of persons by condition occurrence start month, by condition_concept_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 1002 as analysis_id,   
	CAST(ce1.condition_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(condition_era_start_date)*100 + month(condition_era_start_date) AS VARCHAR(255)) as stratum_2,
	null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1002
from
@cdmDatabaseSchema.condition_era ce1
group by ce1.condition_concept_id, 
	YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
;

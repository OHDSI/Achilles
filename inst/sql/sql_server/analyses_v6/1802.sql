-- 1802	Number of persons by measurement occurrence start month, by measurement_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1802 as analysis_id,   
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(measurement_datetime)*100 + month(measurement_datetime) AS VARCHAR(255)) as stratum_2,
	cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1802
from
	@cdmDatabaseSchema.measurement m
group by m.measurement_concept_id, 
	YEAR(measurement_datetime)*100 + month(measurement_datetime)
;

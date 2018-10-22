-- 1820	Number of observation records by condition occurrence start month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 1820 as analysis_id,   
	CAST(YEAR(measurement_datetime)*100 + month(measurement_datetime) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1820
from @cdmDatabaseSchema.measurement m
group by YEAR(measurement_datetime)*100 + month(measurement_datetime)
;

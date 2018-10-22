-- 221	Number of persons by visit start year 

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 221 as analysis_id,   
	CAST(YEAR(visit_start_date) AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_221
from
@cdmDatabaseSchema.visit_occurrence vo1
group by YEAR(visit_start_date)
;

-- 2301	Number of location records, by region_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 2301 as analysis_id,
    CAST(l.region_concept_id AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(l.location_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2301
from
	@cdmDatabaseSchema.location l
group by l.region_concept_id
;

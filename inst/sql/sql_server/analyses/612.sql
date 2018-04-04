-- 612	Number of procedure occurrence records with invalid provider_id

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 612 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(po1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_612
from
	@cdmDatabaseSchema.procedure_occurrence po1
	left join @cdmDatabaseSchema.provider p1
	on p1.provider_id = po1.provider_id
where po1.provider_id is not null
	and p1.provider_id is null
;

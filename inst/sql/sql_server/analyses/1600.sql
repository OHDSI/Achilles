-- 1600	Number of procedure cost records with invalid procedure exposure id

{cdmVersion == '5'}?{
	--HINT DISTRIBUTE_ON_KEY(analysis_id)
	select 1600 as analysis_id,  
	  null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
		COUNT_BIG(pc1.procedure_cost_ID) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1600
	from
		@cdmDatabaseSchema.procedure_cost pc1
			left join @cdmDatabaseSchema.procedure_occurrence po1
			on pc1.procedure_occurrence_id = po1.procedure_occurrence_id
	where po1.procedure_occurrence_id is null
	;
}:{
	--HINT DISTRIBUTE_ON_KEY(analysis_id)
	select 1600 as analysis_id,  
	  null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
		COUNT_BIG(pc1.cost_id) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1600
	from
		@cdmDatabaseSchema.cost pc1
			left join @cdmDatabaseSchema.procedure_occurrence po1
			on pc1.cost_event_id = po1.procedure_occurrence_id
	where po1.procedure_occurrence_id is null
	and pc1.cost_domain_id = 'Procedure'
	;
}

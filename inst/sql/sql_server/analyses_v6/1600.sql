-- 1600	Number of procedure cost records with invalid procedure exposure id

{cdmVersion == '5'}?{
	
	select 1600 as analysis_id,  
	  cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
		COUNT_BIG(pc1.procedure_cost_ID) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1600
	from
		@cdmDatabaseSchema.procedure_cost pc1
			left join @cdmDatabaseSchema.procedure_occurrence po1
			on pc1.procedure_occurrence_id = po1.procedure_occurrence_id
	where po1.procedure_occurrence_id is null
	;
}:{

	select 1600 as analysis_id,  
	  cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
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

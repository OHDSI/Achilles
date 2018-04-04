-- 1610	Number of records by revenue_code_concept_id

{cdmVersion == '5'}?{

	--HINT DISTRIBUTE_ON_KEY(analysis_id)
	select 1610 as analysis_id, 
		CAST(revenue_code_concept_id AS VARCHAR(255)) as stratum_1,
		null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
		COUNT_BIG(pc1.procedure_cost_ID) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1610
	from
		@cdmDatabaseSchema.procedure_cost pc1
	where revenue_code_concept_id is not null
	group by revenue_code_concept_id
	;
	
}:{

	--HINT DISTRIBUTE_ON_KEY(analysis_id)
	select 1610 as analysis_id, 
		CAST(revenue_code_concept_id AS VARCHAR(255)) as stratum_1,
		null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
		COUNT_BIG(pc1.cost_id) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1610
	from
		@cdmDatabaseSchema.cost pc1
	where revenue_code_concept_id is not null
	and pc1.cost_domain_id = 'Procedure'
	group by revenue_code_concept_id
	;

}

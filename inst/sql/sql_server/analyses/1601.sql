-- 1601	Number of procedure cost records with invalid payer plan period id

{cdmVersion == '5'}?{
	--HINT DISTRIBUTE_ON_KEY(analysis_id)
	select 1601 as analysis_id,  
	  null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
		COUNT_BIG(pc1.procedure_cost_ID) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1601
	from
		@cdmDatabaseSchema.procedure_cost pc1
			left join @cdmDatabaseSchema.payer_plan_period ppp1
			on pc1.payer_plan_period_id = ppp1.payer_plan_period_id
	where pc1.payer_plan_period_id is not null
		and ppp1.payer_plan_period_id is null
	;
}:{
	--HINT DISTRIBUTE_ON_KEY(analysis_id)
	select 1601 as analysis_id,  
	  null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
		COUNT_BIG(pc1.cost_id) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1601
	from
		@cdmDatabaseSchema.cost pc1
			left join @cdmDatabaseSchema.payer_plan_period ppp1
			on pc1.payer_plan_period_id = ppp1.payer_plan_period_id
	where pc1.payer_plan_period_id is not null
		and ppp1.payer_plan_period_id is null
		and pc1.cost_domain_id = 'Procedure'
	;
}

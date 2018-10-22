-- 1501	Number of drug cost records with invalid payer plan period id

{cdmVersion == '5'}?{

	select 1501 as analysis_id,  
		cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
		COUNT_BIG(dc1.drug_cost_ID) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1501
	from
		@cdmDatabaseSchema.drug_cost dc1
			left join @cdmDatabaseSchema.payer_plan_period ppp1
			on dc1.payer_plan_period_id = ppp1.payer_plan_period_id
	where dc1.payer_plan_period_id is not null
		and ppp1.payer_plan_period_id is null
	;

}:{
	select 1501 as analysis_id,  
		cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
		COUNT_BIG(dc1.cost_id) as count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1501
	from
		@cdmDatabaseSchema.cost dc1
			left join @cdmDatabaseSchema.payer_plan_period ppp1
			on dc1.payer_plan_period_id = ppp1.payer_plan_period_id
	where dc1.payer_plan_period_id is not null
		and ppp1.payer_plan_period_id is null
		and dc1.cost_domain_id = 'Drug'
	;
}

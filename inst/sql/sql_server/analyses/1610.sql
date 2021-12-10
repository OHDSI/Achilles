-- 1610	Number of records by revenue_code_concept_id

--HINT DISTRIBUTE_ON_KEY(stratum_1)
select 
	1610 as analysis_id, 
	cast(revenue_code_concept_id as varchar(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, 
	cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	count_big(cost_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1610
from @cdmDatabaseSchema.cost
where revenue_code_concept_id is not null
and cost_domain_id = 'Procedure'
group by revenue_code_concept_id
;


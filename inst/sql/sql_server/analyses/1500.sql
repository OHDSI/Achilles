-- 1500	Number of drug cost records with invalid drug exposure id

{cdmVersion == '5'}?{


select 1500 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(dc1.drug_cost_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1500
from
	@cdmDatabaseSchema.drug_cost dc1
		left join @cdmDatabaseSchema.drug_exposure de1
		on dc1.drug_exposure_id = de1.drug_exposure_id
where de1.drug_exposure_id is null
;

}:{

select 1500 as analysis_id,  
	null as stratum_1, null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(dc1.cost_id) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1500
from
	@cdmDatabaseSchema.cost dc1
		left join @cdmDatabaseSchema.drug_exposure de1
		on dc1.cost_event_id = de1.drug_exposure_id
where de1.drug_exposure_id is null
and dc1.cost_domain_id = 'Drug'
;
}

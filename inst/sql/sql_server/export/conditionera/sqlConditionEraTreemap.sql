select 	concept_hierarchy.concept_id,
	isNull(concept_hierarchy.soc_concept_name,'NA') + '||' + isNull(concept_hierarchy.hlgt_concept_name,'NA') + '||' + isNull(concept_hierarchy.hlt_concept_name, 'NA') + '||' + isNull(concept_hierarchy.pt_concept_name,'NA') + '||' + isNull(concept_hierarchy.snomed_concept_name,'NA') concept_path, 
	ar1.count_value as num_persons, 
	ROUND(CAST(1.0*ar1.count_value / denom.count_value AS NUMERIC(8,6)),5) as percent_persons,
	ROUND(ar2.avg_value,5) as length_of_era
from (select * from ACHILLES_results where analysis_id = 1000) ar1
	inner join
	(select stratum_1, avg_value from ACHILLES_results_dist where analysis_id = 1007) ar2
	on ar1.stratum_1 = ar2.stratum_1
	inner join
	(
		select snomed.concept_id, 
			snomed.concept_name as snomed_concept_name,
			pt_to_hlt.pt_concept_name,
			hlt_to_hlgt.hlt_concept_name,
			hlgt_to_soc.hlgt_concept_name,
			soc.concept_name as soc_concept_name
		from	
		(
		select concept_id, concept_name
		from @cdmSchema.dbo.concept
		where vocabulary_id = 1
		) snomed
		left join
			(select c1.concept_id as snomed_concept_id, max(c2.concept_id) as pt_concept_id
			from
			@cdmSchema.dbo.concept c1
			inner join 
			@cdmSchema.dbo.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 1
			inner join 
			@cdmSchema.dbo.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 15
			and c2.concept_class = 'Preferred Term'
			group by c1.concept_id
			) snomed_to_pt
		on snomed.concept_id = snomed_to_pt.snomed_concept_id

		left join
			(select c1.concept_id as pt_concept_id, c1.concept_name as pt_concept_name, max(c2.concept_id) as hlt_concept_id
			from
			@cdmSchema.dbo.concept c1
			inner join 
			@cdmSchema.dbo.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 15
			and c1.concept_class = 'Preferred Term'
			inner join 
			@cdmSchema.dbo.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 15
			and c2.concept_class = 'High Level Term'
			group by c1.concept_id, c1.concept_name
			) pt_to_hlt
		on snomed_to_pt.pt_concept_id = pt_to_hlt.pt_concept_id

		left join
			(select c1.concept_id as hlt_concept_id, c1.concept_name as hlt_concept_name, max(c2.concept_id) as hlgt_concept_id
			from
			@cdmSchema.dbo.concept c1
			inner join 
			@cdmSchema.dbo.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 15
			and c1.concept_class = 'High Level Term'
			inner join 
			@cdmSchema.dbo.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 15
			and c2.concept_class = 'High Level Group Term'
			group by c1.concept_id, c1.concept_name
			) hlt_to_hlgt
		on pt_to_hlt.hlt_concept_id = hlt_to_hlgt.hlt_concept_id

		left join
			(select c1.concept_id as hlgt_concept_id, c1.concept_name as hlgt_concept_name, max(c2.concept_id) as soc_concept_id
			from
			@cdmSchema.dbo.concept c1
			inner join 
			@cdmSchema.dbo.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 15
			and c1.concept_class = 'High Level Group Term'
			inner join 
			@cdmSchema.dbo.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 15
			and c2.concept_class = 'System Organ Class'
			group by c1.concept_id, c1.concept_name
			) hlgt_to_soc
		on hlt_to_hlgt.hlgt_concept_id = hlgt_to_soc.hlgt_concept_id
		left join @cdmSchema.dbo.concept soc
		 on hlgt_to_soc.soc_concept_id = soc.concept_id
	) concept_hierarchy
	on CAST(ar1.stratum_1 AS INT) = concept_hierarchy.concept_id
	,
	(select count_value from ACHILLES_results where analysis_id = 1) denom

order by ar1.count_value desc
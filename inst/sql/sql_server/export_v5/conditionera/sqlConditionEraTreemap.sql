select 	concept_hierarchy.concept_id,
	isNull(concept_hierarchy.soc_concept_name,'NA') + '||' + isNull(concept_hierarchy.hlgt_concept_name,'NA') + '||' + isNull(concept_hierarchy.hlt_concept_name, 'NA') + '||' + isNull(concept_hierarchy.pt_concept_name,'NA') + '||' + isNull(concept_hierarchy.snomed_concept_name,'NA') concept_path, 
	ar1.count_value as num_persons, 
	ROUND(1.0*ar1.count_value / denom.count_value,5) as percent_persons,
	ROUND(ar2.avg_value,5) as length_of_era
from (select cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 1000 GROUP BY analysis_id, stratum_1, count_value) ar1
	inner join
	(select cast(stratum_1 as int) stratum_1, avg_value from @results_database_schema.ACHILLES_results_dist where analysis_id = 1007 GROUP BY analysis_id, stratum_1, avg_value) ar2
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
			from @vocab_database_schema.concept
			where domain_id = 'Condition'
		) snomed
		left join
			(select c1.concept_id as snomed_concept_id, max(c2.concept_id) as pt_concept_id
			from
			@vocab_database_schema.concept c1
			inner join 
			@vocab_database_schema.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.domain_id = 'Condition'
			and ca1.min_levels_of_separation = 1
			inner join 
			@vocab_database_schema.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 'MedDRA'
			group by c1.concept_id
			) snomed_to_pt
		on snomed.concept_id = snomed_to_pt.snomed_concept_id

		left join
			(select c1.concept_id as pt_concept_id, c1.concept_name as pt_concept_name, max(c2.concept_id) as hlt_concept_id
			from
			@vocab_database_schema.concept c1
			inner join 
			@vocab_database_schema.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 'MedDRA'
			and ca1.min_levels_of_separation = 1
			inner join 
			@vocab_database_schema.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 'MedDRA'
			group by c1.concept_id, c1.concept_name
			) pt_to_hlt
		on snomed_to_pt.pt_concept_id = pt_to_hlt.pt_concept_id

		left join
			(select c1.concept_id as hlt_concept_id, c1.concept_name as hlt_concept_name, max(c2.concept_id) as hlgt_concept_id
			from
			@vocab_database_schema.concept c1
			inner join 
			@vocab_database_schema.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 'MedDRA'
			and ca1.min_levels_of_separation = 1
			inner join 
			@vocab_database_schema.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 'MedDRA'
			group by c1.concept_id, c1.concept_name
			) hlt_to_hlgt
		on pt_to_hlt.hlt_concept_id = hlt_to_hlgt.hlt_concept_id

		left join
			(select c1.concept_id as hlgt_concept_id, c1.concept_name as hlgt_concept_name, max(c2.concept_id) as soc_concept_id
			from
			@vocab_database_schema.concept c1
			inner join 
			@vocab_database_schema.concept_ancestor ca1
			on c1.concept_id = ca1.descendant_concept_id
			and c1.vocabulary_id = 'MedDRA'
			and ca1.min_levels_of_separation = 1
			inner join 
			@vocab_database_schema.concept c2
			on ca1.ancestor_concept_id = c2.concept_id
			and c2.vocabulary_id = 'MedDRA'
			group by c1.concept_id, c1.concept_name
			) hlgt_to_soc on hlt_to_hlgt.hlgt_concept_id = hlgt_to_soc.hlgt_concept_id

		left join @vocab_database_schema.concept soc
		 on hlgt_to_soc.soc_concept_id = soc.concept_id

	) concept_hierarchy on ar1.stratum_1 = concept_hierarchy.concept_id
	, (select count_value from @results_database_schema.ACHILLES_results where analysis_id = 1) denom
order by ar1.count_value desc
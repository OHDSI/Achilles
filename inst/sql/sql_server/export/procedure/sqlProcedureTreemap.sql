select 	concept_hierarchy.concept_id,
	isNull(concept_hierarchy.level4_concept_name,'NA') 
	+ '||' + isNull(concept_hierarchy.level3_concept_name,'NA') 
	+ '||' + isNull(concept_hierarchy.level2_concept_name,'NA') 
	+ '||' + isNull(concept_hierarchy.proc_concept_name,'NA') concept_path,
	ar1.count_value as num_persons, 
	1.0*ar1.count_value / denom.count_value as percent_persons,
	1.0*ar2.count_value / ar1.count_value as records_per_person
from (select cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 600 GROUP BY analysis_id, stratum_1, count_value) ar1
	inner join
	(select cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 601 GROUP BY analysis_id, stratum_1, count_value) ar2
	on ar1.stratum_1 = ar2.stratum_1
	inner join
	(
		select procs.concept_id,
		procs.proc_concept_name,
		max(proc_hierarchy.os3_concept_name) as level2_concept_name,
		max(proc_hierarchy.os2_concept_name) as level3_concept_name,
		max(proc_hierarchy.os1_concept_name) as level4_concept_name
	 from
		(
			select c1.concept_id, 
				v1.vocabulary_name + ' ' + c1.concept_code + ': ' + c1.concept_name as proc_concept_name
			from @vocab_database_schema.concept c1
				inner join @vocab_database_schema.vocabulary v1
				on c1.vocabulary_id = v1.vocabulary_id
			WHERE c1.domain_id = 'Procedure'
		) procs
	left join
		(select ca0.DESCENDANT_CONCEPT_ID, max(ca0.ancestor_concept_id) as ancestor_concept_id
		from @vocab_database_schema.concept_ancestor ca0
		inner join
		(select distinct c2.concept_id as os3_concept_id
		 from @vocab_database_schema.concept_ancestor ca1
			inner join
			@vocab_database_schema.concept c1
			on ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
			inner join
			@vocab_database_schema.concept_ancestor ca2
			on c1.concept_id = ca2.ANCESTOR_CONCEPT_ID
			inner join
			@vocab_database_schema.concept c2
			on ca2.DESCENDANT_CONCEPT_ID = c2.concept_id
		 where ca1.ancestor_concept_id = 4040390
		 and ca1.Min_LEVELS_OF_SEPARATION = 2
		 and ca2.MIN_LEVELS_OF_SEPARATION = 1
	  ) t1
	
		on ca0.ANCESTOR_CONCEPT_ID = t1.os3_concept_id

		group by ca0.descendant_concept_id

		) ca1
		on procs.concept_id = ca1.DESCENDANT_CONCEPT_ID
	left join
	(
	 select proc_by_os1.os1_concept_name,
		proc_by_os2.os2_concept_name,
		proc_by_os3.os3_concept_name,
		proc_by_os3.os3_concept_id
	from
	 (select DESCENDANT_CONCEPT_ID as os1_concept_id, concept_name as os1_concept_name
	 from @vocab_database_schema.concept_ancestor ca1
		inner join
		@vocab_database_schema.concept c1
		on ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
	 where ancestor_concept_id = 4040390
	 and Min_LEVELS_OF_SEPARATION = 1
	 ) proc_by_os1

	 inner join
	 (select max(c1.CONCEPT_ID) as os1_concept_id, c2.concept_id as os2_concept_id, c2.concept_name as os2_concept_name
	 from @vocab_database_schema.concept_ancestor ca1
		inner join
		@vocab_database_schema.concept c1
		on ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
		inner join
		@vocab_database_schema.concept_ancestor ca2
		on c1.concept_id = ca2.ANCESTOR_CONCEPT_ID
		inner join
		@vocab_database_schema.concept c2
		on ca2.DESCENDANT_CONCEPT_ID = c2.concept_id
	 where ca1.ancestor_concept_id = 4040390
	 and ca1.Min_LEVELS_OF_SEPARATION = 1
	 and ca2.MIN_LEVELS_OF_SEPARATION = 1
	 group by c2.concept_id, c2.concept_name
	 ) proc_by_os2
	 on proc_by_os1.os1_concept_id = proc_by_os2.os1_concept_id

	 inner join
	 (select max(c1.CONCEPT_ID) as os2_concept_id, c2.concept_id as os3_concept_id, c2.concept_name as os3_concept_name
    from @vocab_database_schema.concept_ancestor ca1
    inner join @vocab_database_schema.concept c1 on ca1.DESCENDANT_CONCEPT_ID = c1.concept_id
    inner join @vocab_database_schema.concept_ancestor ca2 on c1.concept_id = ca2.ANCESTOR_CONCEPT_ID
    inner join @vocab_database_schema.concept c2 on ca2.DESCENDANT_CONCEPT_ID = c2.concept_id
    where ca1.ancestor_concept_id = 4040390
      and ca1.Min_LEVELS_OF_SEPARATION = 2
      and ca2.MIN_LEVELS_OF_SEPARATION = 1
	  group by c2.concept_id, c2.concept_name
	 ) proc_by_os3 on proc_by_os2.os2_concept_id = proc_by_os3.os2_concept_id
	) proc_hierarchy on ca1.ancestor_concept_id = proc_hierarchy.os3_concept_id
	group by procs.concept_id, procs.proc_concept_name

	) concept_hierarchy on ar1.stratum_1 = concept_hierarchy.concept_id
	, (select count_value from @results_database_schema.ACHILLES_results where analysis_id = 1) denom


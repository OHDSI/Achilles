select c.concept_id     as concept_id,
       c.concept_name   as concept_name,
       ar.count_value   as num_persons,
       1.0*count_value/sum(count_value)over() as percent_persons
 from @results_database_schema.achilles_results ar
 join @vocab_database_schema.concept c
   on ar.stratum_1 = cast(c.concept_id as varchar) 
where ar.analysis_id = 301
  and c.concept_id != 0; 

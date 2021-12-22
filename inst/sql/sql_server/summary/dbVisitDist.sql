-- gets the distribution of visits by visit_concept_id in a database

/*Find terminal ancestors in the Visit domain*/
with top_level as (

  SELECT concept_id, concept_name
  FROM @cdm_database_schema.concept 
  LEFT JOIN @cdm_database_schema.concept_ancestor 
 	ON concept_id=descendant_concept_id 
    AND ancestor_concept_id!=descendant_concept_id
  WHERE domain_id='Visit' 
 	AND standard_concept='S'
    AND ancestor_concept_id IS NULL

),

/*Find all descendants of those ancestors*/
visit_roll_up as (
  
  SELECT top_level.concept_id as terminal_ancestor_concept_id, 
  	   top_level.concept_name as terminal_ancestor_concept_name, 
  	   descendant.concept_id as descendant_concept_id, 
  	   descendant.concept_name as descendant_concept_name
  FROM @cdm_database_schema.concept_ancestor
  JOIN top_level  
  	ON top_level.concept_id = ancestor_concept_id
  JOIN @cdm_database_schema.concept descendant 
  	ON descendant.concept_id = descendant_concept_id
  WHERE descendant.domain_id = 'Visit'

)

select c.cdm_source_name,
       c.cdm_source_abbreviation,
       t1.analysis_name,
       t1.terminal_ancestor_concept_id,
       t1.terminal_ancestor_concept_name,
       sum(t1.count_value) as count_value
from @cdm_database_schema.cdm_source c,
(
  select aa.analysis_name, 
         a.visit_concept_id,
         c.descendant_concept_name,
         c.terminal_ancestor_concept_id,
         c.terminal_ancestor_concept_name,
         a.count_value
  from (
          select analysis_id,
                 cast(stratum_1 as numeric) as visit_concept_id,
                 count_value
          from @results_database_schema.achilles_results
          where analysis_id = '201'
        ) a
  join @results_database_schema.achilles_analysis aa
    on a.analysis_id = aa.analysis_id
  join visit_roll_up c
    on a.visit_concept_id = c.descendant_concept_id
) t1

group by c.cdm_source_name,
       c.cdm_source_abbreviation,
       t1.analysis_name,
       t1.terminal_ancestor_concept_id,
       t1.terminal_ancestor_concept_name;

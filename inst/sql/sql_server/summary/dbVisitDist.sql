-- gets the distribution of visits by visit_concept_id in a database

select c.cdm_source_name,
       c.cdm_source_abbreviation,
       t1.analysis_name,
       t1.visit_concept_id,
       t1.concept_name,
       t1.count_value
from @cdm_database_schema.cdm_source c,
(
  select aa.analysis_name, 
         a.visit_concept_id,
         c.concept_name,
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
  join @cdm_database_schema.concept c
    on a.visit_concept_id = c.concept_id
) t1;
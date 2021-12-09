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
         b.visit_concept_id,
         c.concept_name,
         b.count_value
  from (
        select analysis_id,
               visit_concept_id,
               sum(count_value) as count_value
        from (
              select analysis_id,
                     case when cast(stratum_1 as numeric) = 0 then 9202 else cast(stratum_1 as numeric) end as visit_concept_id,
                     count_value
              from @results_database_schema.achilles_results
              where analysis_id = '201'
              ) a
        group by analysis_id, visit_concept_id
      ) b
  join @results_database_schema.achilles_analysis aa
    on b.analysis_id = aa.analysis_id
  join @cdm_database_schema.concept c
    on b.visit_concept_id = c.concept_id
) t1
;

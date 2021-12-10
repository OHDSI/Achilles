-- Generates a one-line database summary table

select c.cdm_source_name,
       c.cdm_source_abbreviation,
       '@country' as country,
       '@provenance' as provenance,
	     t3.attribute_name,
	     round(t3.attribute_value, 2) as attribute_value,
	     rank_order
	     
from @cdm_database_schema.cdm_source c,

(
  select 'Earliest date available' as attribute_name,
         min(cast(stratum_1 as numeric))*1 as attribute_value,
         1 as rank_order
  from @results_database_schema.achilles_results
  where analysis_id = 110
  
  union
  
  select 'Latest date available' as attribute_name,
         max(cast(stratum_1 as numeric))*1 as attribute_value,
         2 as rank_order
  from @results_database_schema.achilles_results
  where analysis_id = 110
  
  union
  
  select 'Number of persons' as attribute_name,
  	count_value as attribute_value,
  	3 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 1

  union
  
  select 'Median age at first Observation Period' as attribute_name,
         median_value as attribute_value,
         4 as rank_order
  from @results_database_schema.achilles_results_dist
  where analysis_id = 103
  
  union
  
  select 'Proportion of female Persons' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         5 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 2 and stratum_1 = '8532'
  
  union
  
  select 'Length of first Observation Period (median years)' as attribute_name,
         1.0*(median_value)/365.25 as attribute_value,
         6 as rank_order
  from @results_database_schema.achilles_results_dist a
  where analysis_id = 105
  
  union
  
  select 'Condition Records per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         7 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 401

  union

  select 'Drug Records per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         8 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 701

  union
  
  select 'Procedure Records per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         9 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 601

  union
  
  select 'Visits per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         10 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 201
  
  union
  
  select 'Inpatient Visits per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         11 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 201 and stratum_1 = '9201'

  union

  select 'Device Records per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         12 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 2101

  union
  
  select 'Observation Records per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         13 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 801

  union

  select 'Measurement Records per Person' as attribute_name,
  	     1.0*(sum(count_value)) / 
         (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         14 as rank_order
  from @results_database_schema.achilles_results a
  where analysis_id = 1801

  union
  
  select 'Measurement records with values per person' as attribute_name,
	       1.0*t1.num_records / 
	       (select count_value from @results_database_schema.achilles_results a where analysis_id = 1) as attribute_value,
         15 as rank_order
  from
  (
    select count(m.measurement_id) as num_records
    from @cdm_database_schema.measurement m
    where value_as_number > 0 or value_as_concept_id > 0
  ) t1
  
)t3
order by rank_order
;


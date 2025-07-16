select 
  c1.concept_id as CONCEPT_ID,
  c1.concept_name as CONCEPT_NAME,
  num.stratum_2 as DOMAIN_ID,
  num.stratum_4 as TOTAL_CHARGE,
  num.stratum_5 as TOTAL_PAID,
  num.count_value as TOTAL_COST
from 
  (select CAST(stratum_1 as bigint) as stratum_1, stratum_2, stratum_4, stratum_5, count_value, analysis_id
   from @results_database_schema.achilles_results
   where analysis_id in (1500, 1600, 1700)
  ) num
inner join @vocab_database_schema.concept c1 
  on num.stratum_1 = c1.concept_id
order by num.count_value desc;
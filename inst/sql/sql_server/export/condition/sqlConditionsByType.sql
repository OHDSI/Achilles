with summary as (
  select cast(stratum_1 as int) condition_concept_id, cast(stratum_2 as int) condition_type_concept_id, sum(count_value) count_value
  FROM  @results_database_schema.achilles_results
  where analysis_id = 405
  GROUP BY stratum_1, stratum_2, count_value
)
select s.condition_concept_id, c.concept_name, s.count_value
from summary s
join @vocab_database_schema.concept c on s.condition_type_concept_id = c.concept_id
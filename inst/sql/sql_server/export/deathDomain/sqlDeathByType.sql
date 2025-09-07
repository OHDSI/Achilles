
select
    c_cause.concept_id as concept_id,
    c_cause.concept_name as concept_name,
    c_type.concept_id as death_type_concept_id,
    c_type.concept_name as death_type_concept_name,
    ar.count_value as count_value
from (
    select cast(stratum_1 as bigint) stratum_1,
           cast(stratum_2 as bigint) stratum_2,
           count_value
    from @results_database_schema.achilles_results
    where analysis_id = 503
    GROUP BY analysis_id, stratum_1, stratum_2, count_value
) ar
inner join @vocab_database_schema.concept c_cause on ar.stratum_1 = c_cause.concept_id
inner join @vocab_database_schema.concept c_type on ar.stratum_2 = c_type.concept_id
order by c_cause.concept_name, c_type.concept_name

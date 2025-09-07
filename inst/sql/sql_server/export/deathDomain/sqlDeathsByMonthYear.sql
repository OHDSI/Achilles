select
    CAST(ar.stratum_1 AS INTEGER) as concept_id,  -- cause_concept_id exported as concept_id
    c.concept_name as concept_name,
    CAST(ar.stratum_2 AS INTEGER) as x_calendar_year,
    CAST(ar.stratum_3 AS INTEGER) as x_calendar_month,
    ar.count_value as y_count_value
from (
    select cast(stratum_1 as bigint) stratum_1,
           cast(stratum_2 as bigint) stratum_2,
           cast(stratum_3 as bigint) stratum_3,
           count_value
    from @results_database_schema.achilles_results
    where analysis_id = 508
    GROUP BY analysis_id, stratum_1, stratum_2, stratum_3, count_value
) ar
inner join @vocab_database_schema.concept c on ar.stratum_1 = c.concept_id
order by c.concept_name, ar.stratum_2, ar.stratum_3
select
    CAST(num.stratum_1 AS INTEGER) as concept_id,
    c.concept_name as concept_name,
    num.stratum_2 as x_calendar_month,
    1000*(1.0*num.count_value/denom.count_value) as y_prevalence_1000pp
from
    (select CAST(stratum_1 as bigint) stratum_1, CAST(stratum_2 as bigint) stratum_2, count_value
     from @results_database_schema.achilles_results
     where analysis_id = 508
     GROUP BY analysis_id, stratum_1, stratum_2, count_value) num
    inner join
    (select CAST(stratum_1 as bigint) stratum_1, count_value
     from @results_database_schema.achilles_results
     where analysis_id = 117
     GROUP BY analysis_id, stratum_1, count_value) denom
    on num.stratum_2 = denom.stratum_1  
    inner join
    @vocab_database_schema.concept c on num.stratum_1 = c.concept_id
order by c.concept_name, num.stratum_2
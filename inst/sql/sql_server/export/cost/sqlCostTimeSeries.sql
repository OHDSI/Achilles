select 
  r.stratum_1 as DOMAIN_ID,
  r.stratum_2 as MONTH_YEAR,
  r.count_value as TOTAL_COST
from (
  select 
    cast(stratum_1 as varchar(255)) as stratum_1,
    stratum_2,
    count_value,
    analysis_id
  from @results_database_schema.achilles_results
  where analysis_id in (1501, 1601, 1701)
) r
order by r.analysis_id, r.stratum_2, r.stratum_1;

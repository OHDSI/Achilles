select 'Length of observation' as series_name, 
	ar1.stratum_1*30 as x_length_of_observation, 
	round(1.0*sum(ar2.count_value) / denom.count_value,5) as y_percent_persons
from (select analysis_id, cast(stratum_1 as int) stratum_1 from @results_database_schema.ACHILLES_results where analysis_id = 108 GROUP BY analysis_id, stratum_1) ar1
inner join
(
	select analysis_id, cast(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 108 GROUP BY analysis_id, stratum_1, count_value
) ar2 on ar1.analysis_id = ar2.analysis_id and ar1.stratum_1 <= ar2.stratum_1,
(
	select count_value from @results_database_schema.ACHILLES_results where analysis_id = 1
) denom
group by ar1.stratum_1*30, denom.count_value
order by ar1.stratum_1*30 asc

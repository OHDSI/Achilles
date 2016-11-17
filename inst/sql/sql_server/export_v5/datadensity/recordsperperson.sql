select t1.table_name as SERIES_NAME,
	t1.stratum_1 as X_CALENDAR_MONTH,
	round(1.0*t1.count_value/denom.count_value,5) as Y_RECORD_COUNT
from
(
	select 'Visit occurrence' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 220 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Condition occurrence' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 420 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Death' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 502 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Procedure occurrence' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 620 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Drug exposure' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 720 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Observation' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 820 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Drug era' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 920 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Condition era' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 1020 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Observation period' as table_name, CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 111 GROUP BY analysis_id, stratum_1, count_value
) t1
inner join
(select CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 117 GROUP BY analysis_id, stratum_1, count_value) denom
on t1.stratum_1 = denom.stratum_1
ORDER BY SERIES_NAME, t1.stratum_1

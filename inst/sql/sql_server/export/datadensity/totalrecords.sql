select table_name as SERIES_NAME,
	stratum_1 as X_CALENDAR_MONTH,
	count_value as Y_RECORD_COUNT
from
(
	select 'Visit occurrence' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 220 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Condition occurrence' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 420 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Death' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 502 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Procedure occurrence' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 620 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Drug exposure' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 720 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Observation' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 820 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Drug era' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 920 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Condition era' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 1020 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Person' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 111 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Measurement' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 1820 GROUP BY analysis_id, stratum_1, count_value
	union all
	select 'Device' as table_name, CAST(stratum_1 as bigint) stratum_1, count_value from @results_database_schema.achilles_results where analysis_id = 2120 GROUP BY analysis_id, stratum_1, count_value	
) t1
ORDER BY SERIES_NAME, stratum_1

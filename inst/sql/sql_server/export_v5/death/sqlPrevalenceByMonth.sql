select num.stratum_1 as x_calendar_month,   -- calendar year, note, there could be blanks
	1000*(1.0*num.count_value/denom.count_value) as y_prevalence_1000pp  --prevalence, per 1000 persons
from 
	(select CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 502 GROUP BY analysis_id, stratum_1, count_value) num
	inner join
	(select CAST(stratum_1 as int) stratum_1, count_value from @results_database_schema.ACHILLES_results where analysis_id = 117 GROUP BY analysis_id, stratum_1, count_value) denom on num.stratum_1 = denom.stratum_1  --calendar year


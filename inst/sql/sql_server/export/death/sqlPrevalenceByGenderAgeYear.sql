select cast(num.stratum_3 * 10 as varchar) + '-' + cast( ( (num.stratum_3 + 1) * 10 ) - 1 as varchar) as trellis_name, --age decile
	c2.concept_name as series_name,  --gender
	num.stratum_1 as x_calendar_year,   -- calendar year, note, there could be blanks
	ROUND(1000*(1.0*num.count_value/denom.count_value),5) as y_prevalence_1000pp  --prevalence, per 1000 persons
from 
	(select CAST(stratum_1 as int) stratum_1, CAST(stratum_2 as int) stratum_2, CAST(stratum_3 as int) stratum_3, count_value from @results_database_schema.ACHILLES_results where analysis_id = 504 GROUP BY analysis_id, stratum_1, stratum_2, stratum_3, count_value) num
	inner join
	(select CAST(stratum_1 as int) stratum_1, CAST(stratum_2 as int) stratum_2, CAST(stratum_3 as int) stratum_3, count_value from @results_database_schema.ACHILLES_results where analysis_id = 116 GROUP BY analysis_id, stratum_1, stratum_2, stratum_3, count_value) denom on num.stratum_1 = denom.stratum_1  --calendar year
		and num.stratum_2 = denom.stratum_2 --gender
		and num.stratum_3 = denom.stratum_3 --age decile
	inner join @vocab_database_schema.concept c2 on num.stratum_2 = c2.concept_id
where c2.concept_id in (8507, 8532)


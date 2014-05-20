select cast(ar1.stratum_1 as int) as MonthYear, 
  ar1.count_value as CountValue, 
	1.0*ar1.count_value / denom.count_value as PercentValue
from (select * from ACHILLES_results where analysis_id = 110) ar1,
	(select count_value from ACHILLES_results where analysis_id = 1) denom
order by ar1.stratum_1 asc
  
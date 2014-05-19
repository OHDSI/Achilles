select cast(ar1.stratum_1 as int) as IntervalIndex, 
	ar1.count_value as CountValue, 
	1.0*ar1.count_value / denom.count_value as PercentValue
from 
(
	select * from ACHILLES_results where analysis_id = 101
) ar1,
(
	select count_value from ACHILLES_results where analysis_id = 1
) denom
order by cast(ar1.stratum_1 as int) asc
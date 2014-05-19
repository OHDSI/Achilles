select  min(cast(ar1.stratum_1 as int)) * 30 as MinValue, 
	max(cast(ar1.stratum_1 as int)) * 30 as MaxValue, 
	30 as IntervalSize
from ACHILLES_analysis aa1
inner join ACHILLES_results ar1 on aa1.analysis_id = ar1.analysis_id,
(
	select count_value from ACHILLES_results where analysis_id = 1
) denom
where aa1.analysis_id = 108
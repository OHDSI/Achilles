select aa1.analysis_name as AttributeName, 
  cast(ar1.stratum_1 as varchar) as AttributeValue
from ACHILLES_analysis aa1
inner join
ACHILLES_results ar1
on aa1.analysis_id = ar1.analysis_id
where aa1.analysis_id = 0

union

select aa1.analysis_name as AttributeName, 
cast(ar1.count_value as varchar) as AttributeValue
from ACHILLES_analysis aa1
inner join
ACHILLES_results ar1
on aa1.analysis_id = ar1.analysis_id
where aa1.analysis_id = 1

order by aa1.analysis_name desc

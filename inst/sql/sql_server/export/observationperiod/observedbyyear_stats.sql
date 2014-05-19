select min(cast(ar1.stratum_1 as int)) as MinValue,
  max(cast(ar1.stratum_1 as int)) as MaxValue,
  1 as IntervalSize
from ACHILLES_results ar1
where ar1.analysis_id = 109
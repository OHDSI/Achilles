IF OBJECT_ID('@resultsDatabaseSchema.achilles_results_derived', 'U') IS NOT NULL 
  DROP TABLE @resultsDatabaseSchema.achilles_results_derived;

with cte_derived
as
(
  @derivedSqls
)
select 
  analysis_id, 
	stratum_1,
	stratum_2,
	statistic_value,
	measure_id
into @resultsDatabaseSchema.achilles_results_derived
from cte_derived;
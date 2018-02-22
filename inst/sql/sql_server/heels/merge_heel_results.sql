IF OBJECT_ID('@resultsDatabaseSchema.achilles_heel_results', 'U') IS NOT NULL 
  DROP TABLE @resultsDatabaseSchema.achilles_heel_results;

with cte_results
as
(
  @resultSqls
)
select 
  analysis_id,
	ACHILLES_HEEL_warning,
	rule_id,
	record_count
into @resultsDatabaseSchema.achilles_heel_results
from cte_results;

{@createTable}?{
  IF OBJECT_ID('@resultsDatabaseSchema.achilles_@detailType', 'U') IS NOT NULL
    drop table @resultsDatabaseSchema.achilles_@detailType;
}
--HINT DISTRIBUTE_ON_KEY(analysis_id)
with cte_merged
as
(
  @detailSqls
)
{!@createTable}?{
  insert into @resultsDatabaseSchema.achilles_@detailType
}
select @fieldNames
{@createTable}?{
  into @resultsDatabaseSchema.achilles_@detailType
}
from cte_merged
{@smallCellCount != ''}?{
  where count_value > @smallCellCount
}
;
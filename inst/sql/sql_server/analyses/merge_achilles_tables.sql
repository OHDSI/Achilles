{@createTable}?{
  IF OBJECT_ID('@resultsDatabaseSchema.achilles_@detailType', 'U') IS NOT NULL
    drop table @resultsDatabaseSchema.achilles_@detailType;
}
--HINT DISTRIBUTE_ON_KEY(analysis_id)
{!@createTable}?{
  insert into @resultsDatabaseSchema.achilles_@detailType
}
select @fieldNames
{@createTable}?{
  into @resultsDatabaseSchema.achilles_@detailType
}
from 
(
  @detailSqls
) Q
{@smallCellCount != ''}?{
  where (analysis_id in (1500, 1600, 1700, 1501, 1601, 1701)
         or count_value > @smallCellCount)
}
;

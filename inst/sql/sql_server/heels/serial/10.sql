--rule31 DQ rule
--ratio of providers to total patients

--compute a derived reatio
--TODO if provider count is zero it will generate division by zero (not sure how dirrerent db engins will react)

select 
  null as analysis_id,
  null as stratum_1,
  null as stratum_2,
  statistic_value,
  measure_id
into @scratchDatabaseSchema@schemaDelim@heelPrefix_serial_rd_@rdNewId
from
(
  select CAST(1.0*ct.total_pts/count_value AS FLOAT) as statistic_value, CAST('Provider:PatientProviderRatio' AS VARCHAR(255)) as measure_id
  from @resultsDatabaseSchema.achilles_results
	join (select count_value as total_pts from @resultsDatabaseSchema.achilles_results r where analysis_id =1) ct
	where analysis_id = 300
) Q
;

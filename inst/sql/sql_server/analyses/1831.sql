-- 1831	Number of measurement records by measurement_concept_id, measurement start month, and observation_period look forward (days).
--      For each measurement_concept_id, year_month combination, stratum_4 represents the proportion of records with at least as many look forward 
--      days as the current row.

--HINT DISTRIBUTE_ON_KEY(stratum_1)
  with lookfwd as (
select m.measurement_concept_id,
       substring(replace(datefromparts(year(m.measurement_date),month(m.measurement_date),1),'-',''),1,6) as year_month,
       datediff(d,m.measurement_date,op.observation_period_end_date) as lookfwd_days,
       count_big(*) as count_value
  from @cdmDatabaseSchema.observation_period op
  join @cdmDatabaseSchema.measurement m
    on m.person_id = op.person_id
 where op.observation_period_end_date >= m.measurement_date
 group by m.measurement_concept_id,
          substring(replace(datefromparts(year(m.measurement_date),month(m.measurement_date),1),'-',''),1,6),
          datediff(d,m.measurement_date,op.observation_period_end_date)
) 
select 1831 as analysis_id,
       cast(measurement_concept_id as varchar(255)) as stratum_1,
       cast(year_month             as varchar(255)) as stratum_2,
       cast(lookfwd_days           as varchar(255)) as stratum_3,
       cast(1.0*sum(count_value)over(partition by measurement_concept_id,year_month order by lookfwd_days desc)/
	            sum(count_value)over(partition by measurement_concept_id,year_month) as varchar(255)) as stratum_4,
       cast(null                   as varchar(255)) as stratum_5,
       count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_1831
  from lookfwd; 

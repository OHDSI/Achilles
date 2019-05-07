-- 830	Number of observation records by observation_concept_id, observation start month, and observation_period look back (days)
--      For each observation_concept_id, year_month combination, stratum_4 represents the proportion of records with at least as many look back 
--      days as the current row.

--HINT DISTRIBUTE_ON_KEY(stratum_1)
  with lookback as (
select o.observation_concept_id,
       substring(replace(datefromparts(year(o.observation_date),month(o.observation_date),1),'-',''),1,6) as year_month,
       datediff(d,op.observation_period_start_date,o.observation_date) as lookback_days,
       count_big(*) as count_value
  from @cdmDatabaseSchema.observation_period op
  join @cdmDatabaseSchema.observation o
    on o.person_id = op.person_id
 where op.observation_period_start_date <= o.observation_date
 group by o.observation_concept_id,
          substring(replace(datefromparts(year(o.observation_date),month(o.observation_date),1),'-',''),1,6),
          datediff(d,op.observation_period_start_date,o.observation_date)
) 
select 830 as analysis_id,
       cast(observation_concept_id as varchar(255)) as stratum_1,
       cast(year_month             as varchar(255)) as stratum_2,
       cast(lookback_days          as varchar(255)) as stratum_3,
       cast(1.0*sum(count_value)over(partition by observation_concept_id,year_month order by lookback_days desc)/
	            sum(count_value)over(partition by observation_concept_id,year_month) as varchar(255)) as stratum_4,
       cast(null                   as varchar(255)) as stratum_5,
       count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_830
  from lookback; 

  
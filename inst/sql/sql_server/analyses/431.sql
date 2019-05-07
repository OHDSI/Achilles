-- 431	Number of condition_occurrence records by condition_concept_id, condition start month, and observation_period look forward (days).
--      For each condition_concept_id, year_month combination, stratum_4 represents the proportion of records with at least as many look forward 
--      days as the current row.

--HINT DISTRIBUTE_ON_KEY(stratum_1)
  with lookfwd as (
select co.condition_concept_id,
       substring(replace(datefromparts(year(co.condition_start_date),month(co.condition_start_date),1),'-',''),1,6) as year_month,
       datediff(d,co.condition_start_date,op.observation_period_end_date) as lookfwd_days,
       count_big(*) as count_value
  from @cdmDatabaseSchema.observation_period op
  join @cdmDatabaseSchema.condition_occurrence co
    on co.person_id = op.person_id
 where op.observation_period_end_date >= co.condition_start_date
 group by co.condition_concept_id,
          substring(replace(datefromparts(year(co.condition_start_date),month(co.condition_start_date),1),'-',''),1,6),
          datediff(d,co.condition_start_date,op.observation_period_end_date)
) 
select 431 as analysis_id,
       cast(condition_concept_id   as varchar(255)) as stratum_1,
       cast(year_month             as varchar(255)) as stratum_2,
       cast(lookfwd_days           as varchar(255)) as stratum_3,
       cast(1.0*sum(count_value)over(partition by condition_concept_id,year_month order by lookfwd_days desc)/
	            sum(count_value)over(partition by condition_concept_id,year_month) as varchar(255)) as stratum_4,
       cast(null                   as varchar(255)) as stratum_5,
       count_value
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_431
  from lookfwd; 
   
  
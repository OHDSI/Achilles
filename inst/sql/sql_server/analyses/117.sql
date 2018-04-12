-- 117	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT
  117 as analysis_id,  
	CAST(t1.obs_month AS VARCHAR(255)) as stratum_1,
	null as stratum_2, null as stratum_3, null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_117
FROM
@cdmDatabaseSchema.observation_period op1
join 
(
  select distinct 
    YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date)  as obs_month
  from 
    @cdmDatabaseSchema.OBSERVATION_PERIOD 
) t1 on YEAR(op1.observation_period_start_date)*100 + MONTH(op1.observation_period_start_date) <= t1.obs_month
	and YEAR(op1.observation_period_end_date)*100 + MONTH(op1.observation_period_end_date) >= t1.obs_month
group by t1.obs_month;
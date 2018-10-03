-- 110	Number of persons with continuous observation in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

--HINT DISTRIBUTE_ON_KEY(stratum_1)
SELECT
  110 as analysis_id,  
	CAST(t1.obs_month AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_110
FROM
@cdmDatabaseSchema.observation_period op1
join 
(
  SELECT DISTINCT 
    YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) AS obs_month,
    DATEFROMPARTS(YEAR(observation_period_start_date), MONTH(observation_period_start_date), 1)
    AS obs_month_start,
    EOMONTH(observation_period_start_date) AS obs_month_end
  FROM @cdmDatabaseSchema.observation_period
) t1 on	op1.observation_period_start_date <= t1.obs_month_start
	and	op1.observation_period_end_date >= t1.obs_month_end
group by t1.obs_month;



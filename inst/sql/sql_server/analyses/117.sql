-- 117	Number of persons with at least one day of observation in each month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
-- generating date key sequences in a cross-dialect compatible fashion
with century as (select '19' num union select '20'), 
tens as (select '0' num union select '1' union select '2' union select '3' union select '4' union select '5' union select '6' union select '7' union select '8' union select '9'),
ones as (select '0' num union select '1' union select '2' union select '3' union select '4' union select '5' union select '6' union select '7' union select '8' union select '9'),
months as (select '01' as num union select '02' union select '03' union select '04' union select '05' union select '06' union select '07' union select '08' union select '09' union select '10' union select '11' union select '12'),
date_keys as (select cast(concat(century.num, tens.num, ones.num,months.num) as int) obs_month from century cross join tens cross join ones cross join months)
SELECT
  117 as analysis_id,  
	CAST(t1.obs_month AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COALESCE(COUNT_BIG(distinct op1.PERSON_ID),0) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_117	
FROM date_keys t1
left join @cdmDatabaseSchema.observation_period op1
on year(op1.observation_period_start_date)*100 + month(op1.observation_period_start_date) <= t1.obs_month
and year(op1.observation_period_end_date)*100 + month(op1.observation_period_end_date) >= t1.obs_month
group by t1.obs_month
having COALESCE(COUNT_BIG(distinct op1.PERSON_ID),0) > 0;
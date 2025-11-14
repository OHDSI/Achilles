-- 117	Number of persons with at least one day of observation in each month

--HINT DISTRIBUTE_ON_KEY(stratum_1)
-- generating date key sequences in a cross-dialect compatible fashion
with century as (select '19' num union select '20' num),
tens as (select '0' num union select '1' num union select '2' num union select '3' num union select '4' num union select '5' num union select '6' num union select '7' num union select '8' num union select '9' num),
ones as (select '0' num union select '1' num union select '2' num union select '3' num union select '4' num union select '5' num union select '6' num union select '7' num union select '8' num union select '9' num),
months as (select '01' as num union select '02' num union select '03' num union select '04' num union select '05' num union select '06' num union select '07' num union select '08' num union select '09' num union select '10' num union select '11' num union select '12' num),
date_keys as (select cast(concat(century.num, tens.num, ones.num,months.num) as int) obs_month from century cross join tens cross join ones cross join months)
SELECT
  117 as analysis_id,
	CAST(t1.obs_month AS VARCHAR(255)) as stratum_1,
	cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
	COALESCE(COUNT_BIG(distinct op1.PERSON_ID),0) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_117
from
  @cdmDatabaseSchema.observation_period op1
  inner join
  date_keys t1 on
    year(op1.observation_period_start_date)*100 + month(op1.observation_period_start_date) <= t1.obs_month
    and
    year(op1.observation_period_end_date)*100 + month(op1.observation_period_end_date) >= t1.obs_month
group by t1.obs_month
having COALESCE(COUNT_BIG(distinct op1.PERSON_ID),0) > 0;

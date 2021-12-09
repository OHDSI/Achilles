-- 109	Number of persons with continuous observation in each year

--HINT DISTRIBUTE_ON_KEY(stratum_1)
-- generating date key sequences in a cross-dialect compatible fashion
with century as (select '19' num union select '20' num), 
tens as (select '0' num union select '1' num union select '2' num union select '3' num union select '4' num union select '5' num union select '6' num union select '7' num union select '8' num union select '9' num),
ones as (select '0' num union select '1' num union select '2' num union select '3' num union select '4' num union select '5' num union select '6' num union select '7' num union select '8' num union select '9' num),
months as (select '01' as num union select '02' num union select '03' num union select '04' num union select '05' num union select '06' num union select '07' num union select '08' num union select '09' num union select '10' num union select '11' num union select '12' num),
date_keys as (select concat(century.num, tens.num, ones.num,months.num)  obs_month from century cross join tens cross join ones cross join months),
-- From date_keys, we just need each year and the first and last day of each year
ymd as (
select cast(left(obs_month,4) as integer)               as obs_year,
       min(cast(right(left(obs_month,6),2) as integer)) as month_start,
       1                                                as day_start,
       max(cast(right(left(obs_month,6),2) as integer)) as month_end,
       31                                               as day_end
  from date_keys
 where right(left(obs_month,6),2) in ('01','12')
 group by left(obs_month,4)
),
-- This gives us each year and the first and last day of the year 
year_ranges as (
select obs_year,
       datefromparts(obs_year,month_start,day_start) obs_year_start,
       datefromparts(obs_year,month_end,day_end) obs_year_end
  from ymd
 where obs_year >= (select min(year(observation_period_start_date)) from @cdmDatabaseSchema.observation_period)
   and obs_year <= (select max(year(observation_period_start_date)) from @cdmDatabaseSchema.observation_period)
) 
SELECT 
	109                               AS analysis_id,  
	CAST(yr.obs_year AS VARCHAR(255)) AS stratum_1,
	CAST(NULL AS VARCHAR(255))        AS stratum_2, 
	CAST(NULL AS VARCHAR(255))        AS stratum_3, 
	CAST(NULL AS VARCHAR(255))        AS stratum_4, 
	CAST(NULL AS VARCHAR(255))        AS stratum_5,
	COUNT_BIG(DISTINCT op.person_id)  AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_109
FROM 
	@cdmDatabaseSchema.observation_period op
CROSS JOIN 
	year_ranges yr
WHERE
	op.observation_period_start_date <= yr.obs_year_start
AND
	op.observation_period_end_date   >= yr.obs_year_end
GROUP BY 
	yr.obs_year
;

-- 116	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

select distinct 
  YEAR(observation_period_start_date) as obs_year 
INTO
  #temp_dates
from 
  @cdmDatabaseSchema.OBSERVATION_PERIOD
;

--HINT DISTRIBUTE_ON_KEY(analysis_id)
select 116 as analysis_id,  
	CAST(t1.obs_year AS VARCHAR(255)) as stratum_1,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(floor((t1.obs_year - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_3,
	null as stratum_4, null as stratum_5,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_116
from
	@cdmDatabaseSchema.PERSON p1
	inner join 
  @cdmDatabaseSchema.observation_period op1
	on p1.person_id = op1.person_id
	,
	#temp_dates t1 
where year(op1.OBSERVATION_PERIOD_START_DATE) <= t1.obs_year
	and year(op1.OBSERVATION_PERIOD_END_DATE) >= t1.obs_year
group by t1.obs_year,
	p1.gender_concept_id,
	floor((t1.obs_year - p1.year_of_birth)/10)
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

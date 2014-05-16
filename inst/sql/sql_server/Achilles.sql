use @results_schema;

IF OBJECT_ID('OSCAR_analysis', 'U') IS NOT NULL
  drop table OSCAR_analysis;

create table OSCAR_analysis
(
	analysis_id int,
	analysis_name varchar(255),
	stratum_1_name varchar(255),
	stratum_2_name varchar(255),
	stratum_3_name varchar(255),
	stratum_4_name varchar(255),
	stratum_5_name varchar(255)
);


IF OBJECT_ID('OSCAR_statistic', 'U') IS NOT NULL
  drop table OSCAR_statistic;

create table OSCAR_statistic
(
	statistic_id int,
	statistic_name varchar(255)
);


IF OBJECT_ID('OSCAR_results', 'U') IS NOT NULL
  drop table OSCAR_results;

create table OSCAR_results
(
	source_name varchar(255),
	analysis_id int,
	statistic_id int,
	stratum_1 varchar(255),
	stratum_2 varchar(255),
	stratum_3 varchar(255),
	stratum_4 varchar(255),
	stratum_5 varchar(255),
	statistic_value float
);


insert into OSCAR_statistic (statistic_id, statistic_name)
	values (1, 'Count');

insert into OSCAR_statistic (statistic_id, statistic_name)
	values (2, 'Percentage');
	
insert into OSCAR_statistic (statistic_id, statistic_name)
	values (3, 'Minimum');
	
insert into OSCAR_statistic (statistic_id, statistic_name)
	values (4, 'Maximum');

insert into OSCAR_statistic (statistic_id, statistic_name)
	values (5, 'Average');

insert into OSCAR_statistic (statistic_id, statistic_name)
	values (6, 'Standard deviation');


--PERSON statistics

insert into OSCAR_analysis (analysis_id, analysis_name)
	values (1, 'Number of persons');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2, 'Number of persons by gender', 'gender_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (3, 'Number of persons by year of birth', 'year_of_birth');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (4, 'Number of persons by race', 'race_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (5, 'Number of persons by ethnicity', 'ethnicity_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (6, 'Number of persons by gender and year of birth', 'gender_concept_id','year_of_birth');


--100. OBSERVATION_PERIOD (joined to PERSON)

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (101, 'Number of persons by age decile, with age at first observation period', 'age decile');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (102, 'Number of persons by gender by age decile, with age at first observation period', 'gender_concept_id', 'age decile');
	
	/****
		comment:  you could drive # of persons by age decile, from # of persons by age decile by gender
		as a general rule:  do full stratification once, and then aggregate across strata to avoid re-calculation
		works for all prevalence calculations...does not work for any distribution statistics
	*****/

insert into OSCAR_analysis (analysis_id, analysis_name)
	values (103, 'Distribution of age at first observation period');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (104, 'Distribution of age at first observation period by gender', 'gender_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name)
	values (105, 'Length of observation (days) of first observation period');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (106, 'Length of observation (days) of first observation period by gender', 'gender_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (107, 'Length of observation (days) of first observation period by age decile', 'age_decile');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (108, 'Number of persons by length of observation period, in 30d increments', 'Observation period length 30d increments');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (109, 'Number of persons with continuous observation in each year', 'calendar year');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (110, 'Number of persons with continuous observation in each month', 'calendar month');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (111, 'Number of persons by observation period start month', 'calendar month');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (112, 'Number of persons by observation period end month', 'calendar month');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (113, 'Number of persons by number of observation periods', 'number of observation periods');


--DRUG_ERA

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name, stratum_5_name)
	values (200, 'Number of persons with at least one drug era, by drug_concept_id by gender by age decile by year of first exposure by drug type', 'drug_concept_id','gender_concept_id','age decile','year of first exposure', 'drug_type_concept_id');

	/****
		comment:  following the logic above:  calculate # of persons by all strata, then we can do pass through data to create aggegregated strata
			specifically, we'll set strata value = 'All'
			then we'll be able to get: 1) by gender, 2) by age decile, 3) by year, 4) by gender and age, 5) by gender and year, 6) by age and year
	*****/

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name, stratum_5_name)
	values (201, 'Number of drug eras, by drug_concept_id by gender by age decile by year of first exposure', 'drug_concept_id','gender_concept_id','age decile','year of first exposure', 'drug_type_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name, stratum_5_name)
	values (202, 'Total length of drug eras, by drug_concept_id by gender by age decile by year of first exposure', 'drug_concept_id','gender_concept_id','age decile','year of first exposure', 'drug_type_concept_id');	

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (203, 'Number of persons by drug era start month, by drug_concept_id', 'drug_concept_id','calendar month');	

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (204, 'Number of exposure records per drug era, by drug_concept_id', 'drug_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name)
	values (205, 'Number of distinct drug ingredients per person');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (206, 'Number of drug era records by drug era start month', 'calendar month');
	
insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (207, 'Distribution of drug era length, by drug_concept_id', 'drug_concept_id');	

			

--DRUG_EXPOSURE

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name, stratum_5_name)
	values (300, 'Number of persons with at least one drug exposure, by drug_concept_id by gender by age decile by year of first exposure', 'drug_concept_id','gender_concept_id','age_decile','year of first exposure', 'drug_type_concept_id');

	/****
		comment:  following the logic above:  calculate # of persons by all strata, then we can do pass through data to create aggegregated strata
			specifically, we'll set strata value = 'All'
			then we'll be able to get: 1) by gender, 2) by age decile, 3) by year, 4) by gender and age, 5) by gender and year, 6) by age and year
	*****/

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name, stratum_5_name)
	values (301, 'Number of drug exposure records, by drug_concept_id by gender by age decile by year of first exposure', 'drug_concept_id','gender_concept_id','age_decile','year of first exposure', 'drug_type_concept_id');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (302, 'Number of persons by drug exposure start month, by drug_concept_id', 'drug_concept_id', 'calendar month');	

insert into OSCAR_analysis (analysis_id, analysis_name)
	values (303, 'Number of distinct drug exposure concepts per person');

insert into OSCAR_analysis (analysis_id, analysis_name, stratum_1_name)
	values (304, 'Number of drug exposure records by drug exposure start month', 'calendar month');





--CONDITION_ERA

--CONDITION_OCCURRENCE

--PROCEDURE_OCCURRENCE

--VISIT_OCCURRENCE

--OBSERVATION

--DEATH

--COHORT

--PAYOR_PLAN_PERIOD

--PROVIDER

--CARE_SITE

--ORGANIZATION


/****
7. generate results for analysis_results


****/


use @CDM_schema;

/*put @results_schema. in front of all insert into OSCAR_results statements*/


--number of persons in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, statistic_value)
select '@source_name' as source_name, 1 as analysis_id, 1 as statistic_id, COUNT(distinct person_id) as statistic_value
from PERSON;


--number/% of persons in database, by gender     (do count now, and then get % later in final run)
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 2 as analysis_id, 1 as statistic_id, gender_concept_id as stratum_1, COUNT(distinct person_id) as statistic_value
from PERSON
group by GENDER_CONCEPT_ID;


--year of birth in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 3 as analysis_id, 1 as statistic_id, year_of_birth as stratum_1, COUNT(distinct person_id) as statistic_value
from PERSON
group by YEAR_OF_BIRTH;


--race in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 4 as analysis_id, 1 as statistic_id, RACE_CONCEPT_ID as stratum_1, COUNT(distinct person_id) as statistic_value
from PERSON
group by RACE_CONCEPT_ID;

--ethnicity in database

insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 5 as analysis_id, 1 as statistic_id, ETHNICITY_CONCEPT_ID as stratum_1, COUNT(distinct person_id) as statistic_value
from PERSON
group by ETHNICITY_CONCEPT_ID;


--gender by year of birth in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, stratum_2, statistic_value)
select '@source_name' as source_name, 6 as analysis_id, 1 as statistic_id,  gender_concept_id as stratum_1, year_of_birth as stratum_2, COUNT(distinct person_id) as statistic_value
from PERSON
group by gender_concept_id, YEAR_OF_BIRTH;


--age decile at first observation in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 101 as analysis_id, 1 as statistic_id,  floor((year(op1.index_date) - p1.YEAR_OF_BIRTH)/10) as stratum_1, COUNT(distinct p1.person_id) as statistic_value
from PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by floor((year(op1.index_date) - p1.YEAR_OF_BIRTH)/10);


--by gender by age decile at first observation in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, stratum_2, statistic_value)
select '@source_name' as source_name, 102 as analysis_id, 1 as statistic_id, p1.gender_concept_id as stratum_1, floor((year(op1.index_date) - p1.YEAR_OF_BIRTH)/10) as stratum_2, COUNT(distinct p1.person_id) as statistic_value
from PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by p1.gender_concept_id, floor((year(op1.index_date) - p1.YEAR_OF_BIRTH)/10);



--age decile at first observation in database
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, statistic_value)
select '@source_name' as source_name, 103 as analysis_id, 
	case when statistic_name = 'min_val' then 3
		when statistic_name = 'max_val' then 4
		when statistic_name = 'avg_val' then 5
		when statistic_name = 'stdev_val' then 6
		else 0 end as statistic_id,
	statistic_value
from
(
select cast(min(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as min_val,
	cast(max(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as max_val,
	cast(avg(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as avg_val,
	cast(stdev(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as stdev_val
from PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
) t1
unpivot (statistic_value for statistic_name in (min_val, max_val, avg_val, stdev_val)) as pvt
;

/*UNPIVOT needs to be in SQL Server->PostgreSQL dialect, need to instead use UNPIVOT*/

--age decile at first observation by gender
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 104 as analysis_id, 
	case when statistic_name = 'min_val' then 3
		when statistic_name = 'max_val' then 4
		when statistic_name = 'avg_val' then 5
		when statistic_name = 'stdev_val' then 6
		else 0 end as statistic_id,
	gender_concept_id as stratum_1, 
	statistic_value
from
(
select gender_concept_id, 
	cast(min(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as min_val,
	cast(max(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as max_val,
	cast(avg(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as avg_val,
	cast(stdev(1.0*(year(op1.index_date) - p1.YEAR_OF_BIRTH)) as float) as stdev_val
from PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by GENDER_CONCEPT_ID
) t1
unpivot (statistic_value for statistic_name in (min_val, max_val, avg_val, stdev_val)) as pvt
;


--Length of observation (days) of first observation period
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, statistic_value)
select '@source_name' as source_name, 105 as analysis_id, 
	case when statistic_name = 'min_val' then 3
		when statistic_name = 'max_val' then 4
		when statistic_name = 'avg_val' then 5
		when statistic_name = 'stdev_val' then 6
		else 0 end as statistic_id,
	statistic_value
from
(
select cast(min(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as min_val,
	cast(max(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as max_val,
	cast(avg(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as avg_val,
	cast(stdev(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as stdev_val
from PERSON p1
	inner join 
	(select person_id, 
		OBSERVATION_PERIOD_START_DATE, 
		OBSERVATION_PERIOD_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
		 from OBSERVATION_PERIOD
	) op1
	on p1.PERSON_ID = op1.PERSON_ID
	where op1.rn1 = 1
) t1
unpivot (statistic_value for statistic_name in (min_val, max_val, avg_val, stdev_val)) as pvt
;



--Length of observation (days) of first observation period by gender
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 106 as analysis_id, 
	case when statistic_name = 'min_val' then 3
		when statistic_name = 'max_val' then 4
		when statistic_name = 'avg_val' then 5
		when statistic_name = 'stdev_val' then 6
		else 0 end as statistic_id,
	gender_concept_id as stratum_1,
	statistic_value
from
(
select p1.gender_concept_id, 
	cast(min(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as min_val,
	cast(max(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as max_val,
	cast(avg(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as avg_val,
	cast(stdev(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as stdev_val
from PERSON p1
	inner join 
	(select person_id, 
		OBSERVATION_PERIOD_START_DATE, 
		OBSERVATION_PERIOD_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
		 from OBSERVATION_PERIOD
	) op1
	on p1.PERSON_ID = op1.PERSON_ID
	where op1.rn1 = 1
group by GENDER_CONCEPT_ID
) t1
unpivot (statistic_value for statistic_name in (min_val, max_val, avg_val, stdev_val)) as pvt
;





insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 107 as analysis_id,  
	case when statistic_name = 'min_val' then 3
		when statistic_name = 'max_val' then 4
		when statistic_name = 'avg_val' then 5
		when statistic_name = 'stdev_val' then 6
		else 0 end as statistic_id,
	age_decile as stratum_1,
	statistic_value
from
(
select floor((year(op1.OBSERVATION_PERIOD_START_DATE) - p1.YEAR_OF_BIRTH)/10) as age_decile, 
	cast(min(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as min_val,
	cast(max(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as max_val,
	cast(avg(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as avg_val,
	cast(stdev(1.0*(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date))) as float) as stdev_val
from PERSON p1
	inner join 
	(select person_id, 
		OBSERVATION_PERIOD_START_DATE, 
		OBSERVATION_PERIOD_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
		 from OBSERVATION_PERIOD
	) op1
	on p1.PERSON_ID = op1.PERSON_ID
	where op1.rn1 = 1
group by floor((year(op1.OBSERVATION_PERIOD_START_DATE) - p1.YEAR_OF_BIRTH)/10)
) t1
unpivot (statistic_value for statistic_name in (min_val, max_val, avg_val, stdev_val)) as pvt
;


--number of persons by length of observation period, in 30d increments
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 108 as analysis_id, 1 as statistic_id, floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30) as stratum_1, COUNT(distinct p1.person_id) as statistic_value
from PERSON p1
	inner join 
	(select person_id, 
		OBSERVATION_PERIOD_START_DATE, 
		OBSERVATION_PERIOD_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
		 from OBSERVATION_PERIOD
	) op1
	on p1.PERSON_ID = op1.PERSON_ID
	where op1.rn1 = 1
group by floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30)
;



--Number of persons with continuous observation in each year
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 109 as analysis_id, 1 as statistic_id, 
	t1.obs_year as stratum_1, COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join observation_period op1
	on p1.person_id = op1.person_id
	,
	(select distinct YEAR(observation_period_start_date) as obs_year 
	from OBSERVATION_PERIOD
	) t1 
where year(op1.OBSERVATION_PERIOD_START_DATE) <= t1.obs_year
	and year(op1.OBSERVATION_PERIOD_END_DATE) >= t1.obs_year
group by t1.obs_year
;

--Number of persons with continuous observation in each month
/*query will need testing within SQL translator due to date issues*/
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 110 as analysis_id, 1 as statistic_id,
	t1.obs_month as stratum_1, COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join observation_period op1
	on p1.person_id = op1.person_id
	,
	(select distinct cast(cast(YEAR(observation_period_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2)), 2) + '01' as date) as obs_month 	
	from OBSERVATION_PERIOD
	) t1 
where op1.OBSERVATION_PERIOD_START_DATE <= t1.obs_month
	and op1.OBSERVATION_PERIOD_END_DATE >= DATEADD(mm,1,t1.obs_month)
group by t1.obs_month
;


--Number of persons by observation period start month
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 111 as analysis_id, 1 as statistic_id,
	cast(cast(YEAR(observation_period_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2)), 2) + '01' as date) as stratum_1, COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join observation_period op1
	on p1.person_id = op1.person_id
group by cast(cast(YEAR(observation_period_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2)), 2) + '01' as date)
;


--Number of persons by observation period end month
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 112 as analysis_id, 1 as statistic_id, 
	cast(cast(YEAR(observation_period_end_date) as varchar(4)) +  RIGHT('0' + CAST(month(OBSERVATION_PERIOD_end_DATE) AS VARCHAR(2)), 2) + '01' as date) as stratum_1, COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join observation_period op1
	on p1.person_id = op1.person_id
group by cast(cast(YEAR(observation_period_end_date) as varchar(4)) +  RIGHT('0' + CAST(month(OBSERVATION_PERIOD_end_DATE) AS VARCHAR(2)), 2) + '01' as date)
;


--Number of persons by number of observation periods
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 113 as analysis_id, 1 as statistic_id, 
	op1.num_periods as stratum_1, COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join (select person_id, COUNT(OBSERVATION_period_start_date) as num_periods from observation_period group by PERSON_ID) op1
	on p1.person_id = op1.person_id
group by op1.num_periods
;


--DRUG_ERA

/***

should add a STRATA for DRUG_TYPE_CONCEPT_ID, but its only in CDMv4, not CDM2  *********************************************

***/


--Number of persons with at least one drug era, by drug_concept_id by gender by age decile by year of first exposure
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, stratum_2, stratum_3, stratum_4, stratum_5, statistic_value)
select '@source_name' as source_name, 200 as analysis_id, 1 as statistic_id,
	de1.DRUG_CONCEPT_ID as stratum_1,
	p1.gender_concept_id as stratum_2,
	FLOOR((YEAR(de1.index_date)-p1.year_of_birth) / 10) as stratum_3,
	YEAR(de1.index_date) as stratum_4,
	de1.drug_type_concept_id as stratum_5,
	COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join
	(select drug_concept_id, person_id, drug_type_concept_id, MIN(DRUG_ERA_START_DATE) as index_date
	from DRUG_ERA
		/****comment:  if I wanted to create counts for all drugs at all levels of drug hierachy, would need to join to CONCEPT_ANCESTOR here****/
	group by DRUG_CONCEPT_ID, PERSON_ID, drug_type_concept_id
	) de1
	on p1.person_id = de1.person_id
group by de1.DRUG_CONCEPT_ID,
	p1.gender_concept_id,
	FLOOR((YEAR(de1.index_date)-p1.year_of_birth) / 10),
	YEAR(de1.index_date),
	de1.drug_type_concept_id
;

--Number of drug eras, by drug_concept_id by gender by age decile by year of first exposure
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, stratum_2, stratum_3, stratum_4, stratum_5, statistic_value)
select '@source_name' as source_name, 201 as analysis_id, 1 as statistic_id, 
	de1.DRUG_CONCEPT_ID as stratum_1,
	p1.gender_concept_id as stratum_2,
	FLOOR((YEAR(de1.index_date)-p1.year_of_birth) / 10) as stratum_3,
	YEAR(de1.index_date) as stratum_4,
	de1.drug_type_concept_id as stratum_5,
	SUM(de1.num_eras) as statistic_value
from
	PERSON p1
	inner join
	(select drug_concept_id, person_id, drug_type_concept_id, MIN(DRUG_ERA_START_DATE) as index_date, COUNT(person_id) as num_eras
	from DRUG_ERA
	group by DRUG_CONCEPT_ID, PERSON_ID, drug_type_concept_id
	) de1
	on p1.person_id = de1.person_id
group by de1.DRUG_CONCEPT_ID,
	p1.gender_concept_id,
	FLOOR((YEAR(de1.index_date)-p1.year_of_birth) / 10),
	YEAR(de1.index_date),
	de1.drug_type_concept_id
;



--Total number of days for length of drug eras, by drug_concept_id by gender by age decile by year of first exposure
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, stratum_2, stratum_3, stratum_4, stratum_5, statistic_value)
select '@source_name' as source_name, 202 as analysis_id, 1 as statistic_id,  
	de1.DRUG_CONCEPT_ID as stratum_1,
	p1.gender_concept_id as stratum_2,
	FLOOR((YEAR(de1.index_date)-p1.year_of_birth) / 10) as stratum_3,
	YEAR(de1.index_date) as stratum_4,
	de1.drug_type_concept_id as stratum_5,
	SUM(de1.drug_era_length) as statistic_value
from
	PERSON p1
	inner join
	(select drug_concept_id, person_id, drug_type_concept_id, MIN(DRUG_ERA_START_DATE) as index_date, SUM(datediff(dd,drug_era_start_date, drug_era_end_date)) as drug_era_length
	from DRUG_ERA
	group by DRUG_CONCEPT_ID, PERSON_ID, drug_type_concept_id
	) de1
	on p1.person_id = de1.person_id
group by de1.DRUG_CONCEPT_ID,
	p1.gender_concept_id,
	FLOOR((YEAR(de1.index_date)-p1.year_of_birth) / 10),
	YEAR(de1.index_date),
	de1.drug_type_concept_id
;


--Number of persons by drug era start month, by drug_concept_id
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, stratum_2, statistic_value)
select '@source_name' as source_name, 203 as analysis_id, 1 as statistic_id,  
	de1.drug_concept_id as stratum_1,
	cast(cast(YEAR(drug_era_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(drug_era_START_DATE) AS VARCHAR(2)), 2) + '01' as date) as stratum_2, 
	COUNT(distinct p1.PERSON_ID) as statistic_value
from
	PERSON p1
	inner join drug_era de1
	on p1.person_id = de1.person_id
group by de1.drug_concept_id, cast(cast(YEAR(drug_era_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(drug_era_START_DATE) AS VARCHAR(2)), 2) + '01' as date)
;



--Number of exposure records per drug era, by drug_concept_id
insert into @results_schema.dbo.OSCAR_results (source_name, analysis_id, statistic_id, stratum_1, statistic_value)
select '@source_name' as source_name, 204 as analysis_id,  
	case when statistic_name = 'min_val' then 3
		when statistic_name = 'max_val' then 4
		when statistic_name = 'avg_val' then 5
		when statistic_name = 'stdev_val' then 6
		else 0 end as statistic_id,
	DRUG_CONCEPT_ID as stratum_1,
	statistic_value
from
(
select drug_concept_id,
	cast(min(1.0*de1.drug_exposure_count) as float) as min_val,
	cast(max(1.0*de1.drug_exposure_count) as float) as max_val,
	cast(avg(1.0*de1.drug_exposure_count) as float) as avg_val,
	cast(stdev(1.0*de1.drug_exposure_count) as float) as stdev_val
from PERSON p1
	inner join drug_era de1
	on p1.PERSON_ID = de1.PERSON_ID
group by drug_concept_id
) t1
unpivot (statistic_value for statistic_name in (min_val, max_val, avg_val, stdev_val)) as pvt
;

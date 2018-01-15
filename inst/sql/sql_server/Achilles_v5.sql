/******************************************************************

# @file ACHILLES_v5.SQL
#
# Copyright 2014 Observational Health Data Sciences and Informatics
#
# This file is part of ACHILLES
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Observational Health Data Sciences and Informatics




*******************************************************************/


/*******************************************************************

Achilles - database profiling summary statistics generation

SQL for OMOP CDM v5


*******************************************************************/

{DEFAULT @cdm_database = 'CDM'}
{DEFAULT @results_database = 'scratch'}
{DEFAULT @results_database_schema = 'scratch.dbo'}
{DEFAULT @source_name = 'CDM NAME'}
{DEFAULT @achilles_version = '1.4.6'}
{DEFAULT @smallcellcount = 5}
{DEFAULT @createTable = TRUE}
{DEFAULT @validateSchema = FALSE}

  /****
    developer comment about general ACHILLES calculation process:  
		you could drive # of persons by age decile, from # of persons by age decile by gender
		as a general rule:  do full stratification once, and then aggregate across strata to avoid re-calculation
		works for all prevalence calculations...does not work for any distribution statistics
	*****/

--{@validateSchema}?{

-- RSD - 2014-10-27
-- Execute a series of quick select statements to verify that the CDM schema
-- has all the proper tables and columns
-- The point is to catch any missing tables/columns here before we spend hours
-- generating results before bombing out

create table #TableCheck
(
  tablename varchar(50)
)
;

insert into #TableCheck (tablename)
select 'care_site'
from (
SELECT
    care_site_id,
		location_id,
		place_of_service_concept_id,
		care_site_source_value,
		place_of_service_source_value,
    row_number() over (order by care_site_id) rn
FROM
		@cdm_database_schema.care_site
) CARE_SITE
WHERE rn = 1;


insert into #TableCheck (tablename)
select 'cohort'
from (
SELECT
		cohort_definition_id,
		cohort_start_date,
		cohort_end_date,
		subject_id,
    row_number() over (order by cohort_definition_id) rn
FROM
		@cdm_database_schema.cohort
) COHORT
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'condition_era'
from (
SELECT
		condition_era_id,
		person_id,
		condition_concept_id,
		condition_era_start_date,
		condition_era_end_date,
		condition_occurrence_count,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.condition_era
) CONDITION_ERA
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'condition_occurrence'
from (
SELECT
		condition_occurrence_id,
		person_id,
		condition_concept_id,
		condition_start_date,
		condition_end_date,
		condition_type_concept_id,
		provider_id,
		visit_occurrence_id,
		condition_source_value,
		condition_source_concept_id,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.condition_occurrence
) condition_occurrence
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'death'
from (
SELECT
		person_id,
		death_date,
		death_type_concept_id,
		cause_concept_id,
		cause_source_value,
		cause_source_concept_id,
    row_number() over (order by person_id) rn
FROM
  @cdm_database_schema.death
) death
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'drug_cost'
from (
SELECT
		drug_cost_id,
		drug_exposure_id,
		paid_copay,
		paid_coinsurance,
		paid_toward_deductible,
		paid_by_payer,
		paid_by_coordination_benefits,
		total_out_of_pocket,
		total_paid,
		ingredient_cost,
		dispensing_fee,
		average_wholesale_price,
		payer_plan_period_id,
    row_number() over (order by drug_cost_id) rn
FROM
		@cdm_database_schema.drug_cost
) drug_cost
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'device_exposure'
from (
SELECT
		device_exposure_id, 
		person_id, 
		device_concept_id, 
		device_exposure_start_date, 
		device_exposure_end_date, 
		device_type_concept_id, 
		unique_device_id, 
		quantity, 
		provider_id, 
		visit_occurrence_id, 
		device_source_value, 
		device_source_concept_id,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.device_exposure
) device_exposure
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'dose_era'
from (
SELECT
		dose_era_id, 
		person_id, 
		drug_concept_id, 
		unit_concept_id, 
		dose_value, 
		dose_era_start_date, 
		dose_era_end_date,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.dose_era
) dose_era
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'drug_cost'
from (
SELECT
		drug_cost_id, 
		drug_exposure_id, 
		currency_concept_id, 
		paid_copay, 
		paid_coinsurance, 
		paid_toward_deductible, 
		paid_by_payer, 
		paid_by_coordination_benefits, 
		total_out_of_pocket, 
		total_paid, 
		ingredient_cost, 
		dispensing_fee, 
		average_wholesale_price, 
		payer_plan_period_id,
    row_number() over (order by drug_cost_id) rn
FROM
		@cdm_database_schema.drug_cost
) drug_cost
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'drug_era'
from (
SELECT
		drug_era_id,
		person_id,
		drug_concept_id,
		drug_era_start_date,
		drug_era_end_date,
		drug_exposure_count,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.drug_era
) drug_era
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'drug_exposure'
from (
SELECT
		drug_exposure_id,
		person_id,
		drug_concept_id,
		drug_exposure_start_date,
		drug_exposure_end_date,
		drug_type_concept_id,
		stop_reason,
		refills,
		quantity,
		days_supply,
		sig,
		route_concept_id,
		effective_drug_dose,
		dose_unit_concept_id,
		lot_number,
		provider_id,
		visit_occurrence_id,
		drug_source_value,
		drug_source_concept_id,
		route_source_value,
		dose_unit_source_value,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.drug_exposure
) drug_exposure
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'location'
from (
SELECT
		location_id,
		address_1,
		address_2,
		city,
		STATE,
		zip,
		county,
		location_source_value,
    row_number() over (order by location_id) rn
FROM
		@cdm_database_schema.location
) location
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'observation'
from (
SELECT
		observation_id,
		person_id,
		observation_concept_id,
		observation_date,
		observation_time,
		value_as_number,
		value_as_string,
		value_as_concept_id,
		qualifier_concept_id,
		unit_concept_id,
		observation_type_concept_id,
		provider_id,
		visit_occurrence_id,
		observation_source_value,
		observation_source_concept_id,
		unit_source_value,
		qualifier_source_value,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.observation
) location
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'observation_period'
from (
SELECT
		observation_period_id,
		person_id,
		observation_period_start_date,
		observation_period_end_date,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.observation_period
) observation_period
WHERE rn = 1;


insert into #TableCheck (tablename)
select 'payer_plan_period'
from (
SELECT
		payer_plan_period_id,
		person_id,
		payer_plan_period_start_date,
		payer_plan_period_end_date,
		payer_source_value,
		plan_source_value,
		family_source_value,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.payer_plan_period
) payer_plan_period
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'person'
from (
SELECT
		person_id,
		gender_concept_id,
		year_of_birth,
		month_of_birth,
		day_of_birth,
		race_concept_id,
		ethnicity_concept_id,
		location_id,
		provider_id,
		care_site_id,
		person_source_value,
		gender_source_value,
		race_source_value,
		ethnicity_source_value,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.person
) person
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'procedure_cost'
from (
SELECT
		procedure_cost_id,
		procedure_occurrence_id,
		currency_concept_id,
		paid_copay,
		paid_coinsurance,
		paid_toward_deductible,
		paid_by_payer,
		paid_by_coordination_benefits,
		total_out_of_pocket,
		total_paid,
		revenue_code_concept_id,
		payer_plan_period_id,
		revenue_code_source_value,
    row_number() over (order by procedure_cost_id) rn
FROM
		@cdm_database_schema.procedure_cost
) procedure_cost
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'procedure_occurrence'
from (
SELECT
		procedure_occurrence_id,
		person_id,
		procedure_concept_id,
		procedure_date,
		procedure_type_concept_id,
		modifier_concept_id,
		quantity,
		provider_id,
		visit_occurrence_id,
		procedure_source_value,
		procedure_source_concept_id,
		qualifier_source_value,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.procedure_occurrence
) procedure_occurrence
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'provider'
from (
SELECT
		provider_id,
		NPI,
		DEA,
		specialty_concept_id,
		care_site_id,
		provider_source_value,
		specialty_source_value,
    row_number() over (order by provider_id) rn
FROM
		@cdm_database_schema.provider
) provider
WHERE rn = 1;

insert into #TableCheck (tablename)
select 'visit_occurrence'
from (
SELECT
		visit_occurrence_id,
		person_id,
		visit_start_date,
		visit_end_date,
		visit_type_concept_id,
		provider_id,
		care_site_id,
		visit_source_value,
		visit_source_concept_id,
    row_number() over (order by person_id) rn
FROM
		@cdm_database_schema.visit_occurrence
) visit_occurrence
WHERE rn = 1;

TRUNCATE TABLE #TableCheck;
DROP TABLE #TableCheck;

--}


--{@createTable}?{

IF OBJECT_ID('@results_database_schema.ACHILLES_analysis', 'U') IS NOT NULL
  drop table @results_database_schema.ACHILLES_analysis;

create table @results_database_schema.ACHILLES_analysis
(
	analysis_id int,
	analysis_name varchar(255),
	stratum_1_name varchar(255),
	stratum_2_name varchar(255),
	stratum_3_name varchar(255),
	stratum_4_name varchar(255),
	stratum_5_name varchar(255)
);


IF OBJECT_ID('@results_database_schema.ACHILLES_results', 'U') IS NOT NULL
  drop table @results_database_schema.ACHILLES_results;

create table @results_database_schema.ACHILLES_results
(
	analysis_id int,
	stratum_1 varchar(255),
	stratum_2 varchar(255),
	stratum_3 varchar(255),
	stratum_4 varchar(255),
	stratum_5 varchar(255),
	count_value bigint
);


IF OBJECT_ID('@results_database_schema.ACHILLES_results_dist', 'U') IS NOT NULL
  drop table @results_database_schema.ACHILLES_results_dist;

create table @results_database_schema.ACHILLES_results_dist
(
	analysis_id int,
	stratum_1 varchar(255),
	stratum_2 varchar(255),
	stratum_3 varchar(255),
	stratum_4 varchar(255),
	stratum_5 varchar(255),
	count_value bigint,
	min_value float,
	max_value float,
	avg_value float,
	stdev_value float,
	median_value float,
	p10_value float,
	p25_value float,
	p75_value float,
	p90_value float
);



--end of creating tables


--populate the tables with names of analyses

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (0, 'Source name');

--000. PERSON statistics

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1, 'Number of persons');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2, 'Number of persons by gender', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (3, 'Number of persons by year of birth', 'year_of_birth');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (4, 'Number of persons by race', 'race_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (5, 'Number of persons by ethnicity', 'ethnicity_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (7, 'Number of persons with invalid provider_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (8, 'Number of persons with invalid location_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (9, 'Number of persons with invalid care_site_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (10, 'Number of all persons by year of birth by gender', 'year_of_birth', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (11, 'Number of non-deceased persons by year of birth by gender', 'year_of_birth', 'gender_concept_id');
	
insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
  values (12, 'Number of persons by race and ethnicity','race_concept_id','ethnicity_concept_id');


--100. OBSERVATION_PERIOD (joined to PERSON)

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (101, 'Number of persons by age, with age at first observation period', 'age');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (102, 'Number of persons by gender by age, with age at first observation period', 'gender_concept_id', 'age');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (103, 'Distribution of age at first observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (104, 'Distribution of age at first observation period by gender', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (105, 'Length of observation (days) of first observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (106, 'Length of observation (days) of first observation period by gender', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (107, 'Length of observation (days) of first observation period by age decile', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (108, 'Number of persons by length of observation period, in 30d increments', 'Observation period length 30d increments');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (109, 'Number of persons with continuous observation in each year', 'calendar year');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (110, 'Number of persons with continuous observation in each month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (111, 'Number of persons by observation period start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (112, 'Number of persons by observation period end month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (113, 'Number of persons by number of observation periods', 'number of observation periods');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (114, 'Number of persons with observation period before year-of-birth');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (115, 'Number of persons with observation period end < observation period start');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name)
	values (116, 'Number of persons with at least one day of observation in each year by gender and age decile', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (117, 'Number of persons with at least one day of observation in each month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
  values (118, 'Number of observation periods with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
  values (119, 'Number of observation period records by period_type_concept_id','period_type_concept_id');




--200- VISIT_OCCURRENCE


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (200, 'Number of persons with at least one visit occurrence, by visit_concept_id', 'visit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (201, 'Number of visit occurrence records, by visit_concept_id', 'visit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (202, 'Number of persons by visit occurrence start month, by visit_concept_id', 'visit_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (203, 'Number of distinct visit occurrence concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (204, 'Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile', 'visit_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (206, 'Distribution of age by visit_concept_id', 'visit_concept_id', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (207, 'Number of visit records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (208, 'Number of visit records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (209, 'Number of visit records with end date < start date');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (210, 'Number of visit records with invalid care_site_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (211, 'Distribution of length of stay by visit_concept_id', 'visit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name )
	values (212, 'Number of persons with at least one visit occurrence, by calendar year by gender by age decile', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (220, 'Number of visit occurrence records by visit occurrence start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (221, 'Number of persons by visit start year', 'calendar year');



--300- PROVIDER
insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (300, 'Number of providers');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (301, 'Number of providers by specialty concept_id', 'specialty_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (302, 'Number of providers with invalid care site id');



--400- CONDITION_OCCURRENCE

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (400, 'Number of persons with at least one condition occurrence, by condition_concept_id', 'condition_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (401, 'Number of condition occurrence records, by condition_concept_id', 'condition_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (402, 'Number of persons by condition occurrence start month, by condition_concept_id', 'condition_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (403, 'Number of distinct condition occurrence concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (404, 'Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile', 'condition_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (405, 'Number of condition occurrence records, by condition_concept_id by condition_type_concept_id', 'condition_concept_id', 'condition_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (406, 'Distribution of age by condition_concept_id', 'condition_concept_id', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (409, 'Number of condition occurrence records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (410, 'Number of condition occurrence records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (411, 'Number of condition occurrence records with end date < start date');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (412, 'Number of condition occurrence records with invalid provider_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (413, 'Number of condition occurrence records with invalid visit_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (420, 'Number of condition occurrence records by condition occurrence start month', 'calendar month');	

--500- DEATH

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (500, 'Number of persons with death, by cause_concept_id', 'cause_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (501, 'Number of records of death, by cause_concept_id', 'cause_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (502, 'Number of persons by death month', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name)
	values (504, 'Number of persons with a death, by calendar year by gender by age decile', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (505, 'Number of death records, by death_type_concept_id', 'death_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (506, 'Distribution of age at death by gender', 'gender_concept_id');


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (509, 'Number of death records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (510, 'Number of death records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (511, 'Distribution of time from death to last condition');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (512, 'Distribution of time from death to last drug');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (513, 'Distribution of time from death to last visit');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (514, 'Distribution of time from death to last procedure');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (515, 'Distribution of time from death to last observation');


--600- PROCEDURE_OCCURRENCE



insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (600, 'Number of persons with at least one procedure occurrence, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (601, 'Number of procedure occurrence records, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (602, 'Number of persons by procedure occurrence start month, by procedure_concept_id', 'procedure_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (603, 'Number of distinct procedure occurrence concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (604, 'Number of persons with at least one procedure occurrence, by procedure_concept_id by calendar year by gender by age decile', 'procedure_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (605, 'Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id', 'procedure_concept_id', 'procedure_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (606, 'Distribution of age by procedure_concept_id', 'procedure_concept_id', 'gender_concept_id');



insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (609, 'Number of procedure occurrence records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (610, 'Number of procedure occurrence records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (612, 'Number of procedure occurrence records with invalid provider_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (613, 'Number of procedure occurrence records with invalid visit_id');


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (620, 'Number of procedure occurrence records  by procedure occurrence start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (691, 'Number of persons that have at least x procedures', 'procedure_id', 'procedure_count');

--700- DRUG_EXPOSURE


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (700, 'Number of persons with at least one drug exposure, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (701, 'Number of drug exposure records, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (702, 'Number of persons by drug exposure start month, by drug_concept_id', 'drug_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (703, 'Number of distinct drug exposure concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (704, 'Number of persons with at least one drug exposure, by drug_concept_id by calendar year by gender by age decile', 'drug_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (705, 'Number of drug exposure records, by drug_concept_id by drug_type_concept_id', 'drug_concept_id', 'drug_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (706, 'Distribution of age by drug_concept_id', 'drug_concept_id', 'gender_concept_id');



insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (709, 'Number of drug exposure records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (710, 'Number of drug exposure records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (711, 'Number of drug exposure records with end date < start date');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (712, 'Number of drug exposure records with invalid provider_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (713, 'Number of drug exposure records with invalid visit_id');



insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (715, 'Distribution of days_supply by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (716, 'Distribution of refills by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (717, 'Distribution of quantity by drug_concept_id', 'drug_concept_id');


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (720, 'Number of drug exposure records  by drug exposure start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (791, 'Number of persons that have at least x drug exposures', 'drug_concept_id', 'drug_count');

--800- OBSERVATION


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (800, 'Number of persons with at least one observation occurrence, by observation_concept_id', 'observation_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (801, 'Number of observation occurrence records, by observation_concept_id', 'observation_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (802, 'Number of persons by observation occurrence start month, by observation_concept_id', 'observation_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (803, 'Number of distinct observation occurrence concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (804, 'Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile', 'observation_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (805, 'Number of observation occurrence records, by observation_concept_id by observation_type_concept_id', 'observation_concept_id', 'observation_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (806, 'Distribution of age by observation_concept_id', 'observation_concept_id', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (807, 'Number of observation occurrence records, by observation_concept_id and unit_concept_id', 'observation_concept_id', 'unit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (809, 'Number of observation records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (810, 'Number of observation records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (812, 'Number of observation records with invalid provider_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (813, 'Number of observation records with invalid visit_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (814, 'Number of observation records with no value (numeric, string, or concept)');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (815, 'Distribution of numeric values, by observation_concept_id and unit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (820, 'Number of observation records  by observation start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (891, 'Number of persons that have at least x observations', 'observation_concept_id', 'observation_count');

--900- DRUG_ERA


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (900, 'Number of persons with at least one drug era, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (901, 'Number of drug era records, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (902, 'Number of persons by drug era start month, by drug_concept_id', 'drug_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (903, 'Number of distinct drug era concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (904, 'Number of persons with at least one drug era, by drug_concept_id by calendar year by gender by age decile', 'drug_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (906, 'Distribution of age by drug_concept_id', 'drug_concept_id', 'gender_concept_id');
	
insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (907, 'Distribution of drug era length, by drug_concept_id', 'drug_concept_id');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (908, 'Number of drug eras without valid person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (909, 'Number of drug eras outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (910, 'Number of drug eras with end date < start date');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (920, 'Number of drug era records  by drug era start month', 'calendar month');

--1000- CONDITION_ERA


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1000, 'Number of persons with at least one condition era, by condition_concept_id', 'condition_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1001, 'Number of condition era records, by condition_concept_id', 'condition_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1002, 'Number of persons by condition era start month, by condition_concept_id', 'condition_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1003, 'Number of distinct condition era concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (1004, 'Number of persons with at least one condition era, by condition_concept_id by calendar year by gender by age decile', 'condition_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1006, 'Distribution of age by condition_concept_id', 'condition_concept_id', 'gender_concept_id');
	
insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1007, 'Distribution of condition era length, by condition_concept_id', 'condition_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1008, 'Number of condition eras without valid person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1009, 'Number of condition eras outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1010, 'Number of condition eras with end date < start date');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1020, 'Number of condition era records by condition era start month', 'calendar month');



--1100- LOCATION


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1100, 'Number of persons by location 3-digit zip', '3-digit zip');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1101, 'Number of persons by location state', 'state');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1102, 'Number of care sites by location 3-digit zip', '3-digit zip');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1103, 'Number of care sites by location state', 'state');


--1200- CARE_SITE

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1200, 'Number of persons by place of service', 'place_of_service_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1201, 'Number of visits by place of service', 'place_of_service_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1202, 'Number of care sites by place of service', 'place_of_service_concept_id');


--1300- ORGANIZATION

--NOT APPLICABLE IN CDMV5
--insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
--	values (1300, 'Number of organizations by place of service', 'place_of_service_concept_id');


--1400- PAYOR_PLAN_PERIOD

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1406, 'Length of payer plan (days) of first payer plan period by gender', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1407, 'Length of payer plan (days) of first payer plan period by age decile', 'age_decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1408, 'Number of persons by length of payer plan period, in 30d increments', 'payer plan period length 30d increments');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1409, 'Number of persons with continuous payer plan in each year', 'calendar year');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1410, 'Number of persons with continuous payer plan in each month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1411, 'Number of persons by payer plan period start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1412, 'Number of persons by payer plan period end month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1413, 'Number of persons by number of payer plan periods', 'number of payer plan periods');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1414, 'Number of persons with payer plan period before year-of-birth');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1415, 'Number of persons with payer plan period end < payer plan period start');

--1500- DRUG_COST



insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1500, 'Number of drug cost records with invalid drug exposure id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1501, 'Number of drug cost records with invalid payer plan period id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1502, 'Distribution of paid copay, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1503, 'Distribution of paid coinsurance, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1504, 'Distribution of paid toward deductible, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1505, 'Distribution of paid by payer, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1506, 'Distribution of paid by coordination of benefit, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1507, 'Distribution of total out-of-pocket, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1508, 'Distribution of total paid, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1509, 'Distribution of ingredient_cost, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1510, 'Distribution of dispensing fee, by drug_concept_id', 'drug_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1511, 'Distribution of average wholesale price, by drug_concept_id', 'drug_concept_id');


--1600- PROCEDURE_COST



insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1600, 'Number of procedure cost records with invalid procedure occurrence id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1601, 'Number of procedure cost records with invalid payer plan period id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1602, 'Distribution of paid copay, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1603, 'Distribution of paid coinsurance, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1604, 'Distribution of paid toward deductible, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1605, 'Distribution of paid by payer, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1606, 'Distribution of paid by coordination of benefit, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1607, 'Distribution of total out-of-pocket, by procedure_concept_id', 'procedure_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1608, 'Distribution of total paid, by procedure_concept_id', 'procedure_concept_id');

--NOT APPLICABLE FOR OMOP CDM v5
--insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
--	values (1609, 'Number of records by disease_class_concept_id', 'disease_class_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1610, 'Number of records by revenue_code_concept_id', 'revenue_code_concept_id');


--1700- COHORT

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1700, 'Number of records by cohort_concept_id', 'cohort_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1701, 'Number of records with cohort end date < cohort start date');

--1800- MEASUREMENT


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1800, 'Number of persons with at least one measurement occurrence, by measurement_concept_id', 'measurement_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1801, 'Number of measurement occurrence records, by measurement_concept_id', 'measurement_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1802, 'Number of persons by measurement occurrence start month, by measurement_concept_id', 'measurement_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1803, 'Number of distinct mesurement occurrence concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (1804, 'Number of persons with at least one mesurement  occurrence, by measurement_concept_id by calendar year by gender by age decile', 'measurement_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1805, 'Number of measurement occurrence records, by measurement_concept_id by measurement_type_concept_id', 'measurement_concept_id', 'measurement_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1806, 'Distribution of age by measurement_concept_id', 'measurement_concept_id', 'gender_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1807, 'Number of measurement occurrence records, by measurement_concept_id and unit_concept_id', 'measurement_concept_id', 'unit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1809, 'Number of measurement records with invalid person_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1810, 'Number of measurement records outside valid observation period');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1812, 'Number of measurement records with invalid provider_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1813, 'Number of measurement records with invalid visit_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1814, 'Number of measurement records with no value (numeric, string, or concept)');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1815, 'Distribution of numeric values, by measurement_concept_id and unit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1816, 'Distribution of low range, by measurement_concept_id and unit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1817, 'Distribution of high range, by observation_concept_id and unit_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1818, 'Number of measurement records below/within/above normal range, by measurement_concept_id and unit_concept_id');


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1820, 'Number of measurement records  by measurement start month', 'calendar month');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1821, 'Number of measurement records with no numeric value');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1891, 'Number of persons that have at least x measurements', 'measurement_concept_id', 'measurement_count');

--1900 REPORTS

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1900, 'Source values mapped to concept_id 0 by table, by source_value', 'table_name', 'source_value');


--2000 Iris (and possibly other new measures) integrated into Achilles

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (2000, 'Number of patients with at least 1 Dx and 1 Rx');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (2001, 'Number of patients with at least 1 Dx and 1 Proc');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (2002, 'Number of patients with at least 1 Meas, 1 Dx and 1 Rx');
	
insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (2003, 'Number of patients with at least 1 Visit');


--2100- DEVICE_EXPOSURE


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2100, 'Number of persons with at least one device exposure, by device_concept_id', 'device_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2101, 'Number of device exposure records, by device_concept_id', 'device_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (2102, 'Number of persons by device records  start month, by device_concept_id', 'device_concept_id', 'calendar month');	

--2103 was not implemented at this point

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (2104, 'Number of persons with at least one device exposure, by device_concept_id by calendar year by gender by age decile', 'device_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (2105, 'Number of device exposure records, by device_concept_id by device_type_concept_id', 'device_concept_id', 'device_type_concept_id');



--2200- NOTE


insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2200, 'Number of persons with at least one note by  note_type_concept_id', 'note_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2201, 'Number of note records, by note_type_concept_id', 'note_type_concept_id');




--end of importing values into analysis lookup table

--} : {else if not createTable
delete from @results_database_schema.ACHILLES_results where analysis_id IN (@list_of_analysis_ids);
delete from @results_database_schema.ACHILLES_results_dist where analysis_id IN (@list_of_analysis_ids);
--}

/****
7. generate results for analysis_results


****/

--{0 IN (@list_of_analysis_ids)}?{
-- 0	cdm name, version of Achilles and date when pre-computations were executed
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3,count_value)
select 0 as analysis_id,  CAST('@source_name' AS VARCHAR(255)) as stratum_1, CAST('@achilles_version' AS VARCHAR(255)) as stratum_2, CAST(GETDATE() AS VARCHAR(255)) as stratum_3,COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value)
select 0 as analysis_id, CAST('@source_name' AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON;

--}


/********************************************

ACHILLES Analyses on PERSON table

*********************************************/



--{1 IN (@list_of_analysis_ids)}?{
-- 1	Number of persons
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1 as analysis_id,  COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON;
--}


--{2 IN (@list_of_analysis_ids)}?{
-- 2	Number of persons by gender
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 2 as analysis_id,  CAST(gender_concept_id AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
group by GENDER_CONCEPT_ID;
--}



--{3 IN (@list_of_analysis_ids)}?{
-- 3	Number of persons by year of birth
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 3 as analysis_id,  CAST(year_of_birth AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
group by YEAR_OF_BIRTH;
--}


--{4 IN (@list_of_analysis_ids)}?{
-- 4	Number of persons by race
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 4 as analysis_id,  CAST(RACE_CONCEPT_ID AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
group by RACE_CONCEPT_ID;
--}



--{5 IN (@list_of_analysis_ids)}?{
-- 5	Number of persons by ethnicity
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 5 as analysis_id,  CAST(ETHNICITY_CONCEPT_ID AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
group by ETHNICITY_CONCEPT_ID;
--}





--{7 IN (@list_of_analysis_ids)}?{
-- 7	Number of persons with invalid provider_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 7 as analysis_id,  COUNT_BIG(p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	left join @cdm_database_schema.provider pr1
	on p1.provider_id = pr1.provider_id
where p1.provider_id is not null
	and pr1.provider_id is null
;
--}



--{8 IN (@list_of_analysis_ids)}?{
-- 8	Number of persons with invalid location_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 8 as analysis_id,  COUNT_BIG(p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	left join @cdm_database_schema.location l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.location_id is null
;
--}


--{9 IN (@list_of_analysis_ids)}?{
-- 9	Number of persons with invalid care_site_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 9 as analysis_id,  COUNT_BIG(p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	left join @cdm_database_schema.care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.care_site_id is null
;
--}



--{10 IN (@list_of_analysis_ids)}?{
-- 10	Number of all persons by year of birth and by gender
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 10 as analysis_id,  CAST(year_of_birth AS VARCHAR(255)) as stratum_1,
  CAST(gender_concept_id AS VARCHAR(255)) as stratum_2,
  COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
group by YEAR_OF_BIRTH, gender_concept_id;
--}


--{11 IN (@list_of_analysis_ids)}?{
-- 11	Number of non-deceased persons by year of birth and by gender
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 11 as analysis_id,  CAST(year_of_birth AS VARCHAR(255)) as stratum_1,
  CAST(gender_concept_id AS VARCHAR(255)) as stratum_2,
  COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
where person_id not in (select person_id from @cdm_database_schema.DEATH)
group by YEAR_OF_BIRTH, gender_concept_id;
--}



--{12 IN (@list_of_analysis_ids)}?{
-- 12	Number of persons by race and ethnicity
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 12 as analysis_id, CAST(RACE_CONCEPT_ID AS VARCHAR(255)) as stratum_1, CAST(ETHNICITY_CONCEPT_ID AS VARCHAR(255)) as stratum_2, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON
group by RACE_CONCEPT_ID,ETHNICITY_CONCEPT_ID;
--}

/********************************************

ACHILLES Analyses on OBSERVATION_PERIOD table

*********************************************/

--{101 IN (@list_of_analysis_ids)}?{
-- 101	Number of persons by age, with age at first observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 101 as analysis_id,   CAST(year(op1.index_date) - p1.YEAR_OF_BIRTH AS VARCHAR(255)) as stratum_1, COUNT_BIG(p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from @cdm_database_schema.OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by year(op1.index_date) - p1.YEAR_OF_BIRTH;
--}



--{102 IN (@list_of_analysis_ids)}?{
-- 102	Number of persons by gender by age, with age at first observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 102 as analysis_id,  CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_1, CAST(year(op1.index_date) - p1.YEAR_OF_BIRTH AS VARCHAR(255)) as stratum_2, COUNT_BIG(p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from @cdm_database_schema.OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by p1.gender_concept_id, year(op1.index_date) - p1.YEAR_OF_BIRTH;
--}


--{103 IN (@list_of_analysis_ids)}?{
-- 103	Distribution of age at first observation period
with rawData (person_id, age_value) as
(
select p.person_id, 
  MIN(YEAR(observation_period_start_date)) - P.YEAR_OF_BIRTH as age_value
  from @cdm_database_schema.PERSON p
  JOIN @cdm_database_schema.OBSERVATION_PERIOD op on p.person_id = op.person_id
  group by p.person_id, p.year_of_birth
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * age_value) AS FLOAT) as avg_value,
  CAST(stdev(age_value) AS FLOAT) as stdev_value,
  min(age_value) as min_value,
  max(age_value) as max_value,
  count_big(*) as total
  FROM rawData
),
ageStats (age_value, total, rn) as
(
  select age_value, count_big(*) as total, row_number() over (order by age_value) as rn
  from rawData
  group by age_value
),
ageStatsPrior (age_value, total, accumulated) as
(
  select s.age_value, s.total, sum(p.total) as accumulated
  from ageStats s
  join ageStats p on p.rn <= s.rn
  group by s.age_value, s.total, s.rn
)
select 103 as analysis_id,
  o.total as count_value,
	o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then age_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then age_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then age_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then age_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then age_value end) as p90_value
INTO #tempResults
from ageStatsPrior p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;
--}



--{104 IN (@list_of_analysis_ids)}?{
-- 104	Distribution of age at first observation period by gender
with rawData (gender_concept_id, age_value) as
(
  select p.gender_concept_id, MIN(YEAR(observation_period_start_date)) - P.YEAR_OF_BIRTH as age_value
	from @cdm_database_schema.PERSON p
	JOIN @cdm_database_schema.OBSERVATION_PERIOD op on p.person_id = op.person_id
	group by p.person_id,p.gender_concept_id, p.year_of_birth
),
overallStats (gender_concept_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select gender_concept_id,
  CAST(avg(1.0 * age_value) AS FLOAT) as avg_value,
  CAST(stdev(age_value) AS FLOAT) as stdev_value,
  min(age_value) as min_value,
  max(age_value) as max_value,
  count_big(*) as total
  FROM rawData
  group by gender_concept_id
),
ageStats (gender_concept_id, age_value, total, rn) as
(
  select gender_concept_id, age_value, count_big(*) as total, row_number() over (order by age_value) as rn
  FROM rawData
  group by gender_concept_id, age_value
),
ageStatsPrior (gender_concept_id, age_value, total, accumulated) as
(
  select s.gender_concept_id, s.age_value, s.total, sum(p.total) as accumulated
  from ageStats s
  join ageStats p on s.gender_concept_id = p.gender_concept_id and p.rn <= s.rn
  group by s.gender_concept_id, s.age_value, s.total, s.rn
)
select 104 as analysis_id,
  CAST(o.gender_concept_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then age_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then age_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then age_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then age_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then age_value end) as p90_value
INTO #tempResults
from ageStatsPrior p
join overallStats o on p.gender_concept_id = o.gender_concept_id
GROUP BY o.gender_concept_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;
--}

--{105 IN (@list_of_analysis_ids)}?{
-- 105	Length of observation (days) of first observation period
with rawData (count_value) as
(
  select count_value
  FROM
  (
    select DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
  	  ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
    from @cdm_database_schema.OBSERVATION_PERIOD op
	) op
	where op.rn = 1
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
  CAST(stdev(count_value) AS FLOAT) as stdev_value,
  min(count_value) as min_value,
  max(count_value) as max_value,
  count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM
  (
    select DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
  	  ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
    from @cdm_database_schema.OBSERVATION_PERIOD op
	) op
  where op.rn = 1
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 105 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;
--}


--{106 IN (@list_of_analysis_ids)}?{
-- 106	Length of observation (days) of first observation period by gender
with rawData(gender_concept_id, count_value) as
(
  select p.gender_concept_id, op.count_value
  FROM
  (
    select person_id, DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value,
      ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
    from @cdm_database_schema.OBSERVATION_PERIOD op
	) op
  JOIN @cdm_database_schema.PERSON p on op.person_id = p.person_id
	where op.rn = 1
),
overallStats (gender_concept_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select gender_concept_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
  group by gender_concept_id
),
statsView (gender_concept_id, count_value, total, rn) as
(
  select gender_concept_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by gender_concept_id, count_value
),
priorStats (gender_concept_id,count_value, total, accumulated) as
(
  select s.gender_concept_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.gender_concept_id = p.gender_concept_id and p.rn <= s.rn
  group by s.gender_concept_id, s.count_value, s.total, s.rn
)
select 106 as analysis_id,
  CAST(o.gender_concept_id AS VARCHAR(255)) as gender_concept_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value end) as p90_value
INTO #tempResults
from priorStats p
join overallStats o on p.gender_concept_id = o.gender_concept_id
GROUP BY o.gender_concept_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, gender_concept_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
FROM #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{107 IN (@list_of_analysis_ids)}?{
-- 107	Length of observation (days) of first observation period by age decile

with rawData (age_decile, count_value) as
(
  select floor((year(op.OBSERVATION_PERIOD_START_DATE) - p.YEAR_OF_BIRTH)/10) as age_decile,
    DATEDIFF(dd,op.observation_period_start_date, op.observation_period_end_date) as count_value
  FROM
  (
    select person_id, 
  		op.observation_period_start_date,
  		op.observation_period_end_date,
      ROW_NUMBER() over (PARTITION by op.person_id order by op.observation_period_start_date asc) as rn
    from @cdm_database_schema.OBSERVATION_PERIOD op
  ) op
  JOIN @cdm_database_schema.PERSON p on op.person_id = p.person_id
  where op.rn = 1
),
overallStats (age_decile, avg_value, stdev_value, min_value, max_value, total) as
(
  select age_decile,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by age_decile
),
statsView (age_decile, count_value, total, rn) as
(
  select age_decile,
    count_value, 
		count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by age_decile, count_value
),
priorStats (age_decile,count_value, total, accumulated) as
(
  select s.age_decile, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.age_decile = p.age_decile and p.rn <= s.rn
  group by s.age_decile, s.count_value, s.total, s.rn
)
select 107 as analysis_id,
  CAST(o.age_decile AS VARCHAR(255)) as age_decile,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.age_decile = o.age_decile
GROUP BY o.age_decile, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, age_decile, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
FROM #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{108 IN (@list_of_analysis_ids)}?{
-- 108	Number of persons by length of observation period, in 30d increments
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 108 as analysis_id,  CAST(floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30) AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join 
	(select person_id, 
		OBSERVATION_PERIOD_START_DATE, 
		OBSERVATION_PERIOD_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by observation_period_start_date asc) as rn1
		 from @cdm_database_schema.OBSERVATION_PERIOD
	) op1
	on p1.PERSON_ID = op1.PERSON_ID
	where op1.rn1 = 1
group by floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30)
;
--}




--{109 IN (@list_of_analysis_ids)}?{
-- 109	Number of persons with continuous observation in each year
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

SELECT DISTINCT 
  YEAR(observation_period_start_date) AS obs_year,
  DATEFROMPARTS(YEAR(observation_period_start_date), 1, 1) AS obs_year_start,
  DATEFROMPARTS(YEAR(observation_period_start_date), 12, 31) AS obs_year_end
INTO
  #temp_dates
FROM @cdm_database_schema.observation_period
;

INSERT INTO @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
SELECT 
  109 AS analysis_id,  
	CAST(obs_year AS VARCHAR(255)) AS stratum_1,
	COUNT_BIG(DISTINCT person_id) AS count_value
FROM @cdm_database_schema.observation_period,
	#temp_dates
WHERE  
		observation_period_start_date <= obs_year_start
	AND 
		observation_period_end_date >= obs_year_end
GROUP BY 
	obs_year
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;
--}


--{110 IN (@list_of_analysis_ids)}?{
-- 110	Number of persons with continuous observation in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

SELECT DISTINCT 
  YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) AS obs_month,
  DATEFROMPARTS(YEAR(observation_period_start_date), MONTH(OBSERVATION_PERIOD_START_DATE), 1) AS obs_month_start,
  EOMONTH(observation_period_start_date) AS obs_month_end
INTO
  #temp_dates
FROM @cdm_database_schema.observation_period
;


INSERT INTO @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
SELECT 
  110 AS analysis_id, 
	CAST(obs_month AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(DISTINCT person_id) AS count_value
FROM
	@cdm_database_schema.observation_period,
	#temp_Dates
WHERE 
		observation_period_start_date <= obs_month_start
	AND
		observation_period_end_date >= obs_month_end
GROUP BY 
	obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;
--}



--{111 IN (@list_of_analysis_ids)}?{
-- 111	Number of persons by observation period start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 111 as analysis_id, 
	CAST(YEAR(observation_period_start_date)*100 + month(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation_period op1
group by YEAR(observation_period_start_date)*100 + month(OBSERVATION_PERIOD_START_DATE)
;
--}



--{112 IN (@list_of_analysis_ids)}?{
-- 112	Number of persons by observation period end month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 112 as analysis_id,  
	CAST(YEAR(observation_period_end_date)*100 + month(observation_period_end_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation_period op1
group by YEAR(observation_period_end_date)*100 + month(observation_period_end_date)
;
--}


--{113 IN (@list_of_analysis_ids)}?{
-- 113	Number of persons by number of observation periods
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 113 as analysis_id,  
	CAST(op1.num_periods AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	(select person_id, COUNT_BIG(OBSERVATION_period_start_date) as num_periods from @cdm_database_schema.OBSERVATION_PERIOD group by PERSON_ID) op1
group by op1.num_periods
;
--}

--{114 IN (@list_of_analysis_ids)}?{
-- 114	Number of persons with observation period before year-of-birth
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 114 as analysis_id,  
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join (select person_id, MIN(year(OBSERVATION_period_start_date)) as first_obs_year from @cdm_database_schema.OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.person_id = op1.person_id
where p1.year_of_birth > op1.first_obs_year
;
--}

--{115 IN (@list_of_analysis_ids)}?{
-- 115	Number of persons with observation period end < start
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 115 as analysis_id,  
	COUNT_BIG(op1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation_period op1
where op1.observation_period_end_date < op1.observation_period_start_date
;
--}



--{116 IN (@list_of_analysis_ids)}?{
-- 116	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

select distinct 
  YEAR(observation_period_start_date) as obs_year 
INTO
  #temp_dates
from 
  @cdm_database_schema.OBSERVATION_PERIOD
;

insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 116 as analysis_id,  
	CAST(t1.obs_year AS VARCHAR(255)) as stratum_1,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(floor((t1.obs_year - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_3,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join 
  @cdm_database_schema.observation_period op1
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
--}


--{117 IN (@list_of_analysis_ids)}?{
-- 117	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

select distinct 
  YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date)  as obs_month
into 
  #temp_dates
from 
  @cdm_database_schema.OBSERVATION_PERIOD
;

insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 117 as analysis_id,  
	CAST(t1.obs_month AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation_period op1,
	#temp_dates t1 
where YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) <= t1.obs_month
	and YEAR(observation_period_end_date)*100 + MONTH(observation_period_end_date) >= t1.obs_month
group by t1.obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;
--}


--{118 IN (@list_of_analysis_ids)}?{
-- 118  Number of observation period records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 118 as analysis_id,
  COUNT_BIG(op1.PERSON_ID) as count_value
from
  @cdm_database_schema.observation_period op1
  left join @cdm_database_schema.PERSON p1
  on p1.person_id = op1.person_id
where p1.person_id is null
;
--}

--{119 IN (@list_of_analysis_ids)}?{
-- 119  Number of observation period records by period_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1,count_value)
select 119 as analysis_id,
  CAST(op1.period_type_concept_id AS VARCHAR(255)) as stratum_1,
  COUNT_BIG(*) as count_value
from
  @cdm_database_schema.observation_period op1
group by op1.period_type_concept_id
;
--}


/********************************************

ACHILLES Analyses on VISIT_OCCURRENCE table

*********************************************/


--{200 IN (@list_of_analysis_ids)}?{
-- 200	Number of persons with at least one visit occurrence, by visit_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 200 as analysis_id, 
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct vo1.PERSON_ID) as count_value
from
	@cdm_database_schema.visit_occurrence vo1
group by vo1.visit_concept_id
;
--}


--{201 IN (@list_of_analysis_ids)}?{
-- 201	Number of visit occurrence records, by visit_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 201 as analysis_id, 
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	@cdm_database_schema.visit_occurrence vo1
group by vo1.visit_concept_id
;
--}



--{202 IN (@list_of_analysis_ids)}?{
-- 202	Number of persons by visit occurrence start month, by visit_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 202 as analysis_id,   
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(visit_start_date)*100 + month(visit_start_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.visit_occurrence vo1
group by vo1.visit_concept_id, 
	YEAR(visit_start_date)*100 + month(visit_start_date)
;
--}



--{203 IN (@list_of_analysis_ids)}?{
-- 203	Number of distinct visit occurrence concepts per person

with rawData(person_id, count_value) as
(
    select vo1.person_id, COUNT_BIG(distinct vo1.visit_concept_id) as count_value
		from @cdm_database_schema.visit_occurrence vo1
		group by vo1.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 203 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
INTO #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
FROM #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}



--{204 IN (@list_of_analysis_ids)}?{
-- 204	Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 204 as analysis_id,   
	CAST(vo1.visit_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(visit_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(visit_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.visit_occurrence vo1
on p1.person_id = vo1.person_id
group by vo1.visit_concept_id, 
	YEAR(visit_start_date),
	p1.gender_concept_id,
	floor((year(visit_start_date) - p1.year_of_birth)/10)
;
--}





--{206 IN (@list_of_analysis_ids)}?{
-- 206	Distribution of age by visit_concept_id

with rawData(stratum1_id, stratum2_id, count_value) as
(
  select vo1.visit_concept_id,
  	p1.gender_concept_id,
		vo1.visit_start_year - p1.year_of_birth as count_value
	from @cdm_database_schema.PERSON p1
	inner join 
  (
		select person_id, visit_concept_id, min(year(visit_start_date)) as visit_start_year
		from @cdm_database_schema.visit_occurrence
		group by person_id, visit_concept_id
	) vo1 on p1.person_id = vo1.person_id
),
overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id,
    stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
	group by stratum1_id, stratum2_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select stratum1_id, stratum2_id, count_value, count_big(*) as total, row_number() over (partition by stratum1_id, stratum2_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, stratum2_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 206 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{207 IN (@list_of_analysis_ids)}?{
--207	Number of visit records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 207 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	@cdm_database_schema.visit_occurrence vo1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = vo1.person_id
where p1.person_id is null
;
--}


--{208 IN (@list_of_analysis_ids)}?{
--208	Number of visit records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 208 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	@cdm_database_schema.visit_occurrence vo1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = vo1.person_id
	and vo1.visit_start_date >= op1.observation_period_start_date
	and vo1.visit_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}

--{209 IN (@list_of_analysis_ids)}?{
--209	Number of visit records with end date < start date
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 209 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	@cdm_database_schema.visit_occurrence vo1
where visit_end_date < visit_start_date
;
--}

--{210 IN (@list_of_analysis_ids)}?{
--210	Number of visit records with invalid care_site_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 210 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	@cdm_database_schema.visit_occurrence vo1
	left join @cdm_database_schema.care_site cs1
	on vo1.care_site_id = cs1.care_site_id
where vo1.care_site_id is not null
	and cs1.care_site_id is null
;
--}


--{211 IN (@list_of_analysis_ids)}?{
-- 211	Distribution of length of stay by visit_concept_id
with rawData(stratum_id, count_value) as
(
  select visit_concept_id, datediff(dd,visit_start_date,visit_end_date) as count_value
  from @cdm_database_schema.visit_occurrence
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
  group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 211 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{212 IN (@list_of_analysis_ids)}?{
-- 212	Number of persons with at least one visit occurrence by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 212 as analysis_id,   
	CAST(YEAR(visit_start_date) AS VARCHAR(255)),
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(floor((year(visit_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_3,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.visit_occurrence vo1
on p1.person_id = vo1.person_id
group by 
	YEAR(visit_start_date),
	p1.gender_concept_id,
	floor((year(visit_start_date) - p1.year_of_birth)/10)
;
--}


--{220 IN (@list_of_analysis_ids)}?{
-- 220	Number of visit occurrence records by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 220 as analysis_id,   
	CAST(YEAR(visit_start_date)*100 + month(visit_start_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.visit_occurrence vo1
group by YEAR(visit_start_date)*100 + month(visit_start_date)
;
--}


--{221 IN (@list_of_analysis_ids)}?{
-- 221	Number of persons by visit start year 
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 221 as analysis_id,   
	CAST(YEAR(visit_start_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.visit_occurrence vo1
group by YEAR(visit_start_date)
;
--}





/********************************************

ACHILLES Analyses on PROVIDER table

*********************************************/


--{300 IN (@list_of_analysis_ids)}?{
-- 300	Number of providers
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 300 as analysis_id,  COUNT_BIG(distinct provider_id) as count_value
from @cdm_database_schema.provider;
--}


--{301 IN (@list_of_analysis_ids)}?{
-- 301	Number of providers by specialty concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 301 as analysis_id,  CAST(specialty_concept_id AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct provider_id) as count_value
from @cdm_database_schema.provider
group by specialty_CONCEPT_ID;
--}

--{302 IN (@list_of_analysis_ids)}?{
-- 302	Number of providers with invalid care site id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 302 as analysis_id,  COUNT_BIG(provider_id) as count_value
from @cdm_database_schema.provider p1
	left join @cdm_database_schema.care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.care_site_id is null
;
--}



/********************************************

ACHILLES Analyses on CONDITION_OCCURRENCE table

*********************************************/


--{400 IN (@list_of_analysis_ids)}?{
-- 400	Number of persons with at least one condition occurrence, by condition_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 400 as analysis_id, 
	CAST(co1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
group by co1.condition_CONCEPT_ID
;
--}


--{401 IN (@list_of_analysis_ids)}?{
-- 401	Number of condition occurrence records, by condition_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 401 as analysis_id, 
	CAST(co1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
group by co1.condition_CONCEPT_ID
;
--}



--{402 IN (@list_of_analysis_ids)}?{
-- 402	Number of persons by condition occurrence start month, by condition_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 402 as analysis_id,   
	CAST(co1.condition_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(condition_start_date)*100 + month(condition_start_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.condition_occurrence co1
group by co1.condition_concept_id, 
	YEAR(condition_start_date)*100 + month(condition_start_date)
;
--}



--{403 IN (@list_of_analysis_ids)}?{
-- 403	Number of distinct condition occurrence concepts per person
with rawData(person_id, count_value) as
(
  select person_id, COUNT_BIG(distinct condition_concept_id) as num_conditions
  from @cdm_database_schema.condition_occurrence
	group by person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 403 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}



--{404 IN (@list_of_analysis_ids)}?{
-- 404	Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 404 as analysis_id,   
	CAST(co1.condition_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(condition_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(condition_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.condition_occurrence co1
on p1.person_id = co1.person_id
group by co1.condition_concept_id, 
	YEAR(condition_start_date),
	p1.gender_concept_id,
	floor((year(condition_start_date) - p1.year_of_birth)/10)
;
--}

--{405 IN (@list_of_analysis_ids)}?{
-- 405	Number of condition occurrence records, by condition_concept_id by condition_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 405 as analysis_id, 
	CAST(co1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(co1.condition_type_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
group by co1.condition_CONCEPT_ID,	
	co1.condition_type_concept_id
;
--}



--{406 IN (@list_of_analysis_ids)}?{
-- 406	Distribution of age by condition_concept_id
select co1.condition_concept_id as subject_id,
  p1.gender_concept_id,
	(co1.condition_start_year - p1.year_of_birth) as count_value
INTO #rawData_406
from @cdm_database_schema.PERSON p1
inner join 
(
	select person_id, condition_concept_id, min(year(condition_start_date)) as condition_start_year
	from @cdm_database_schema.condition_occurrence
	group by person_id, condition_concept_id
) co1 on p1.person_id = co1.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_406
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_406
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 406 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
INTO #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

truncate Table #rawData_406;
drop table #rawData_406;

--}


--{409 IN (@list_of_analysis_ids)}?{
-- 409	Number of condition occurrence records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 409 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = co1.person_id
where p1.person_id is null
;
--}


--{410 IN (@list_of_analysis_ids)}?{
-- 410	Number of condition occurrence records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 410 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = co1.person_id
	and co1.condition_start_date >= op1.observation_period_start_date
	and co1.condition_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{411 IN (@list_of_analysis_ids)}?{
-- 411	Number of condition occurrence records with end date < start date
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 411 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
where co1.condition_end_date < co1.condition_start_date
;
--}


--{412 IN (@list_of_analysis_ids)}?{
-- 412	Number of condition occurrence records with invalid provider_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 412 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
	left join @cdm_database_schema.provider p1
	on p1.provider_id = co1.provider_id
where co1.provider_id is not null
	and p1.provider_id is null
;
--}

--{413 IN (@list_of_analysis_ids)}?{
-- 413	Number of condition occurrence records with invalid visit_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 413 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_occurrence co1
	left join @cdm_database_schema.visit_occurrence vo1
	on co1.visit_occurrence_id = vo1.visit_occurrence_id
where co1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}

--{420 IN (@list_of_analysis_ids)}?{
-- 420	Number of condition occurrence records by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 420 as analysis_id,   
	CAST(YEAR(condition_start_date)*100 + month(condition_start_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.condition_occurrence co1
group by YEAR(condition_start_date)*100 + month(condition_start_date)
;
--}



/********************************************

ACHILLES Analyses on DEATH table

*********************************************/



--{500 IN (@list_of_analysis_ids)}?{
-- 500	Number of persons with death, by cause_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 500 as analysis_id, 
	CAST(d1.cause_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct d1.PERSON_ID) as count_value
from
	@cdm_database_schema.death d1
group by d1.cause_concept_id
;
--}


--{501 IN (@list_of_analysis_ids)}?{
-- 501	Number of records of death, by cause_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 501 as analysis_id, 
	CAST(d1.cause_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(d1.PERSON_ID) as count_value
from
	@cdm_database_schema.death d1
group by d1.cause_concept_id
;
--}



--{502 IN (@list_of_analysis_ids)}?{
-- 502	Number of persons by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 502 as analysis_id,   
	CAST(YEAR(death_date)*100 + month(death_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.death d1
group by YEAR(death_date)*100 + month(death_date)
;
--}



--{504 IN (@list_of_analysis_ids)}?{
-- 504	Number of persons with a death, by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 504 as analysis_id,   
	CAST(YEAR(death_date) AS VARCHAR(255)) as stratum_1,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(floor((year(death_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_3,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.death d1
on p1.person_id = d1.person_id
group by YEAR(death_date),
	p1.gender_concept_id,
	floor((year(death_date) - p1.year_of_birth)/10)
;
--}

--{505 IN (@list_of_analysis_ids)}?{
-- 505	Number of death records, by death_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 505 as analysis_id, 
	CAST(death_type_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
	@cdm_database_schema.death d1
group by death_type_concept_id
;
--}



--{506 IN (@list_of_analysis_ids)}?{
-- 506	Distribution of age by condition_concept_id

with rawData(stratum_id, count_value) as
(
  select p1.gender_concept_id,
    d1.death_year - p1.year_of_birth as count_value
  from @cdm_database_schema.PERSON p1
  inner join
  (select person_id, min(year(death_date)) as death_year
  from @cdm_database_schema.death
  group by person_id
  ) d1
  on p1.person_id = d1.person_id
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
  group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 506 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;

drop table #tempResults;
--}



--{509 IN (@list_of_analysis_ids)}?{
-- 509	Number of death records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 509 as analysis_id, 
	COUNT_BIG(d1.PERSON_ID) as count_value
from
	@cdm_database_schema.death d1
		left join @cdm_database_schema.person p1
		on d1.person_id = p1.person_id
where p1.person_id is null
;
--}



--{510 IN (@list_of_analysis_ids)}?{
-- 510	Number of death records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 510 as analysis_id, 
	COUNT_BIG(d1.PERSON_ID) as count_value
from
	@cdm_database_schema.death d1
		left join @cdm_database_schema.observation_period op1
		on d1.person_id = op1.person_id
		and d1.death_date >= op1.observation_period_start_date
		and d1.death_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{511 IN (@list_of_analysis_ids)}?{
-- 511	Distribution of time from death to last condition
insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 511 as analysis_id,
  COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	CAST(avg(1.0*count_value) AS FLOAT) as avg_value,
	CAST(stdev(count_value) AS FLOAT) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(*) over () + 1) as p1
from @cdm_database_schema.death d1
	inner join
	(
		select person_id, max(condition_start_date) as max_date
		from @cdm_database_schema.condition_occurrence
		group by person_id
	) t0 on d1.person_id = t0.person_id
) t1
;
--}


--{512 IN (@list_of_analysis_ids)}?{
-- 512	Distribution of time from death to last drug
with rawData(count_value) as
(
  select datediff(dd,d1.death_date, t0.max_date) as count_value
  from @cdm_database_schema.death d1
  inner join
	(
		select person_id, max(drug_exposure_start_date) as max_date
		from @cdm_database_schema.drug_exposure
		group by person_id
	) t0
	on d1.person_id = t0.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 512 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
FROM #tempResults
;

truncate table #tempResults;

drop table #tempResults;


--}


--{513 IN (@list_of_analysis_ids)}?{
-- 513	Distribution of time from death to last visit
with rawData(count_value) as
(
  select datediff(dd,d1.death_date, t0.max_date) as count_value
  from @cdm_database_schema.death d1
	inner join
	(
		select person_id, max(visit_start_date) as max_date
		from @cdm_database_schema.visit_occurrence
		group by person_id
	) t0
	on d1.person_id = t0.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 513 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;

drop table #tempResults;

--}


--{514 IN (@list_of_analysis_ids)}?{
-- 514	Distribution of time from death to last procedure
with rawData(count_value) as
(
  select datediff(dd,d1.death_date, t0.max_date) as count_value
  from @cdm_database_schema.death d1
	inner join
	(
		select person_id, max(procedure_date) as max_date
		from @cdm_database_schema.procedure_occurrence
		group by person_id
	) t0
	on d1.person_id = t0.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 514 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;

drop table #tempResults;

--}


--{515 IN (@list_of_analysis_ids)}?{
-- 515	Distribution of time from death to last observation
with rawData(count_value) as
(
  select datediff(dd,d1.death_date, t0.max_date) as count_value
  from @cdm_database_schema.death d1
	inner join
	(
		select person_id, max(observation_date) as max_date
		from @cdm_database_schema.observation
		group by person_id
	) t0
	on d1.person_id = t0.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 515 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}



/********************************************

ACHILLES Analyses on PROCEDURE_OCCURRENCE table

*********************************************/



--{600 IN (@list_of_analysis_ids)}?{
-- 600	Number of persons with at least one procedure occurrence, by procedure_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 600 as analysis_id, 
	CAST(po1.procedure_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
group by po1.procedure_CONCEPT_ID
;
--}


--{601 IN (@list_of_analysis_ids)}?{
-- 601	Number of procedure occurrence records, by procedure_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 601 as analysis_id, 
	CAST(po1.procedure_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
group by po1.procedure_CONCEPT_ID
;
--}



--{602 IN (@list_of_analysis_ids)}?{
-- 602	Number of persons by procedure occurrence start month, by procedure_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 602 as analysis_id,   
	CAST(po1.procedure_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(procedure_date)*100 + month(procedure_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.procedure_occurrence po1
group by po1.procedure_concept_id, 
	YEAR(procedure_date)*100 + month(procedure_date)
;
--}



--{603 IN (@list_of_analysis_ids)}?{
-- 603	Number of distinct procedure occurrence concepts per person
with rawData(count_value) as
(
  select COUNT_BIG(distinct po.procedure_concept_id) as num_procedures
	from @cdm_database_schema.procedure_occurrence po
	group by po.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 603 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}



--{604 IN (@list_of_analysis_ids)}?{
-- 604	Number of persons with at least one procedure occurrence, by procedure_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 604 as analysis_id,   
	CAST(po1.procedure_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(procedure_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(procedure_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.procedure_occurrence po1
on p1.person_id = po1.person_id
group by po1.procedure_concept_id, 
	YEAR(procedure_date),
	p1.gender_concept_id,
	floor((year(procedure_date) - p1.year_of_birth)/10)
;
--}

--{605 IN (@list_of_analysis_ids)}?{
-- 605	Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 605 as analysis_id, 
	CAST(po1.procedure_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(po1.procedure_type_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
group by po1.procedure_CONCEPT_ID,	
	po1.procedure_type_concept_id
;
--}



--{606 IN (@list_of_analysis_ids)}?{
-- 606	Distribution of age by procedure_concept_id
select po1.procedure_concept_id as subject_id,
  p1.gender_concept_id,
	po1.procedure_start_year - p1.year_of_birth as count_value
INTO #rawData_606
from @cdm_database_schema.PERSON p1
inner join
(
	select person_id, procedure_concept_id, min(year(procedure_date)) as procedure_start_year
	from @cdm_database_schema.procedure_occurrence
	group by person_id, procedure_concept_id
) po1 on p1.person_id = po1.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_606
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_606
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 606 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;
truncate table #rawData_606;
drop table #rawData_606;

--}

--{609 IN (@list_of_analysis_ids)}?{
-- 609	Number of procedure occurrence records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 609 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = po1.person_id
where p1.person_id is null
;
--}


--{610 IN (@list_of_analysis_ids)}?{
-- 610	Number of procedure occurrence records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 610 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = po1.person_id
	and po1.procedure_date >= op1.observation_period_start_date
	and po1.procedure_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}



--{612 IN (@list_of_analysis_ids)}?{
-- 612	Number of procedure occurrence records with invalid provider_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 612 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
	left join @cdm_database_schema.provider p1
	on p1.provider_id = po1.provider_id
where po1.provider_id is not null
	and p1.provider_id is null
;
--}

--{613 IN (@list_of_analysis_ids)}?{
-- 613	Number of procedure occurrence records with invalid visit_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 613 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	@cdm_database_schema.procedure_occurrence po1
	left join @cdm_database_schema.visit_occurrence vo1
	on po1.visit_occurrence_id = vo1.visit_occurrence_id
where po1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}


--{620 IN (@list_of_analysis_ids)}?{
-- 620	Number of procedure occurrence records by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 620 as analysis_id,   
	CAST(YEAR(procedure_date)*100 + month(procedure_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.procedure_occurrence po1
group by YEAR(procedure_date)*100 + month(procedure_date)
;
--}


--{691 IN (@list_of_analysis_ids)}?{
-- 691	Number of total persons that have at least x procedures
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 
	691 as analysis_id,
	CAST(procedure_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(prc_cnt AS VARCHAR(255)) as stratum_2,
	sum(count(person_id))	over (partition by procedure_concept_id order by prc_cnt desc) as count_value
from (
	select 
		p.procedure_concept_id, 
		count(p.procedure_occurrence_id) as prc_cnt, 
		p.person_id
	from @cdm_database_schema.procedure_occurrence p 
	group by p.person_id, p.procedure_concept_id
) cnt_q
group by cnt_q.procedure_concept_id, cnt_q.prc_cnt;
--}

/********************************************

ACHILLES Analyses on DRUG_EXPOSURE table

*********************************************/




--{700 IN (@list_of_analysis_ids)}?{
-- 700	Number of persons with at least one drug occurrence, by drug_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 700 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
group by de1.drug_CONCEPT_ID
;
--}


--{701 IN (@list_of_analysis_ids)}?{
-- 701	Number of drug occurrence records, by drug_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 701 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
group by de1.drug_CONCEPT_ID
;
--}



--{702 IN (@list_of_analysis_ids)}?{
-- 702	Number of persons by drug occurrence start month, by drug_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 702 as analysis_id,   
	CAST(de1.drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.drug_exposure de1
group by de1.drug_concept_id, 
	YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date)
;
--}



--{703 IN (@list_of_analysis_ids)}?{
-- 703	Number of distinct drug exposure concepts per person
with rawData(count_value) as
(
  select num_drugs as count_value
	from
	(
		select de1.person_id, COUNT_BIG(distinct de1.drug_concept_id) as num_drugs
		from
		@cdm_database_schema.drug_exposure de1
		group by de1.person_id
	) t0
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 703 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}



--{704 IN (@list_of_analysis_ids)}?{
-- 704	Number of persons with at least one drug occurrence, by drug_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 704 as analysis_id,   
	CAST(de1.drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(drug_exposure_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(drug_exposure_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.drug_exposure de1
on p1.person_id = de1.person_id
group by de1.drug_concept_id, 
	YEAR(drug_exposure_start_date),
	p1.gender_concept_id,
	floor((year(drug_exposure_start_date) - p1.year_of_birth)/10)
;
--}

--{705 IN (@list_of_analysis_ids)}?{
-- 705	Number of drug occurrence records, by drug_concept_id by drug_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 705 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(de1.drug_type_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
group by de1.drug_CONCEPT_ID,	
	de1.drug_type_concept_id
;
--}



--{706 IN (@list_of_analysis_ids)}?{
-- 706	Distribution of age by drug_concept_id
select de1.drug_concept_id as subject_id,
  p1.gender_concept_id,
	de1.drug_start_year - p1.year_of_birth as count_value
INTO #rawData_706
from @cdm_database_schema.PERSON p1
inner join
(
	select person_id, drug_concept_id, min(year(drug_exposure_start_date)) as drug_start_year
	from @cdm_database_schema.drug_exposure
	group by person_id, drug_concept_id
) de1 on p1.person_id = de1.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_706
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_706
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 706 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;


truncate table #rawData_706;
drop table #rawData_706;

truncate table #tempResults;
drop table #tempResults;

--}



--{709 IN (@list_of_analysis_ids)}?{
-- 709	Number of drug exposure records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 709 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = de1.person_id
where p1.person_id is null
;
--}


--{710 IN (@list_of_analysis_ids)}?{
-- 710	Number of drug exposure records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 710 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = de1.person_id
	and de1.drug_exposure_start_date >= op1.observation_period_start_date
	and de1.drug_exposure_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{711 IN (@list_of_analysis_ids)}?{
-- 711	Number of drug exposure records with end date < start date
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 711 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
where de1.drug_exposure_end_date < de1.drug_exposure_start_date
;
--}


--{712 IN (@list_of_analysis_ids)}?{
-- 712	Number of drug exposure records with invalid provider_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 712 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
	left join @cdm_database_schema.provider p1
	on p1.provider_id = de1.provider_id
where de1.provider_id is not null
	and p1.provider_id is null
;
--}

--{713 IN (@list_of_analysis_ids)}?{
-- 713	Number of drug exposure records with invalid visit_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 713 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_exposure de1
	left join @cdm_database_schema.visit_occurrence vo1
	on de1.visit_occurrence_id = vo1.visit_occurrence_id
where de1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}



--{715 IN (@list_of_analysis_ids)}?{
-- 715	Distribution of days_supply by drug_concept_id
with rawData(stratum_id, count_value) as
(
  select drug_concept_id,
		days_supply as count_value
	from @cdm_database_schema.drug_exposure 
	where days_supply is not null
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
	group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 715 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{716 IN (@list_of_analysis_ids)}?{
-- 716	Distribution of refills by drug_concept_id
with rawData(stratum_id, count_value) as
(
  select drug_concept_id,
    refills as count_value
	from @cdm_database_schema.drug_exposure 
	where refills is not null
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
	group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 716 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}



--{717 IN (@list_of_analysis_ids)}?{
-- 717	Distribution of quantity by drug_concept_id
with rawData(stratum_id, count_value) as
(
  select drug_concept_id,
    CAST(quantity AS FLOAT) as count_value
  from @cdm_database_schema.drug_exposure 
	where quantity is not null
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
	group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 717 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}


--{720 IN (@list_of_analysis_ids)}?{
-- 720	Number of drug exposure records by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 720 as analysis_id,   
	CAST(YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.drug_exposure de1
group by YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date)
;
--}

--{791 IN (@list_of_analysis_ids)}?{
-- 791	Number of total persons that have at least x drug exposures
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 
	791 as analysis_id,
	CAST(drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(drg_cnt AS VARCHAR(255)) as stratum_2,
	sum(count(person_id))	over (partition by drug_concept_id order by drg_cnt desc) as count_value
from (
	select 
		d.drug_concept_id, 
		count(d.drug_exposure_id) as drg_cnt, 
		d.person_id
	from @cdm_database_schema.drug_exposure d 
	group by d.person_id, d.drug_concept_id
) cnt_q
group by cnt_q.drug_concept_id, cnt_q.drg_cnt;
--}

/********************************************

ACHILLES Analyses on OBSERVATION table

*********************************************/



--{800 IN (@list_of_analysis_ids)}?{
-- 800	Number of persons with at least one observation occurrence, by observation_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 800 as analysis_id, 
	CAST(o1.observation_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
group by o1.observation_CONCEPT_ID
;
--}


--{801 IN (@list_of_analysis_ids)}?{
-- 801	Number of observation occurrence records, by observation_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 801 as analysis_id, 
	CAST(o1.observation_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
group by o1.observation_CONCEPT_ID
;
--}



--{802 IN (@list_of_analysis_ids)}?{
-- 802	Number of persons by observation occurrence start month, by observation_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 802 as analysis_id,   
	CAST(o1.observation_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(observation_date)*100 + month(observation_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.observation o1
group by o1.observation_concept_id, 
	YEAR(observation_date)*100 + month(observation_date)
;
--}



--{803 IN (@list_of_analysis_ids)}?{
-- 803	Number of distinct observation occurrence concepts per person
with rawData(count_value) as
(
  select num_observations as count_value
  from
	(
  	select o1.person_id, COUNT_BIG(distinct o1.observation_concept_id) as num_observations
  	from
  	@cdm_database_schema.observation o1
  	group by o1.person_id
	) t0
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 803 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;

drop table #tempResults;


--}



--{804 IN (@list_of_analysis_ids)}?{
-- 804	Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 804 as analysis_id,   
	CAST(o1.observation_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(observation_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(observation_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.observation o1
on p1.person_id = o1.person_id
group by o1.observation_concept_id, 
	YEAR(observation_date),
	p1.gender_concept_id,
	floor((year(observation_date) - p1.year_of_birth)/10)
;
--}

--{805 IN (@list_of_analysis_ids)}?{
-- 805	Number of observation occurrence records, by observation_concept_id by observation_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 805 as analysis_id, 
	CAST(o1.observation_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(o1.observation_type_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
group by o1.observation_CONCEPT_ID,	
	o1.observation_type_concept_id
;
--}



--{806 IN (@list_of_analysis_ids)}?{
-- 806	Distribution of age by observation_concept_id
select o1.observation_concept_id as subject_id,
  p1.gender_concept_id,
	o1.observation_start_year - p1.year_of_birth as count_value
INTO #rawData_806
from @cdm_database_schema.PERSON p1
inner join
(
	select person_id, observation_concept_id, min(year(observation_date)) as observation_start_year
	from @cdm_database_schema.observation
	group by person_id, observation_concept_id
) o1
on p1.person_id = o1.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_806
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_806
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 806 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_806;
drop table #rawData_806;

truncate table #tempResults;
drop table #tempResults;


--}

--{807 IN (@list_of_analysis_ids)}?{
-- 807	Number of observation occurrence records, by observation_concept_id and unit_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 807 as analysis_id, 
	CAST(o1.observation_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(o1.unit_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
group by o1.observation_CONCEPT_ID,
	o1.unit_concept_id
;
--}





--{809 IN (@list_of_analysis_ids)}?{
-- 809	Number of observation records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 809 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = o1.person_id
where p1.person_id is null
;
--}


--{810 IN (@list_of_analysis_ids)}?{
-- 810	Number of observation records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 810 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = o1.person_id
	and o1.observation_date >= op1.observation_period_start_date
	and o1.observation_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}



--{812 IN (@list_of_analysis_ids)}?{
-- 812	Number of observation records with invalid provider_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 812 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
	left join @cdm_database_schema.provider p1
	on p1.provider_id = o1.provider_id
where o1.provider_id is not null
	and p1.provider_id is null
;
--}

--{813 IN (@list_of_analysis_ids)}?{
-- 813	Number of observation records with invalid visit_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 813 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
	left join @cdm_database_schema.visit_occurrence vo1
	on o1.visit_occurrence_id = vo1.visit_occurrence_id
where o1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}


--{814 IN (@list_of_analysis_ids)}?{
-- 814	Number of observation records with no value (numeric, string, or concept)
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 814 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	@cdm_database_schema.observation o1
where o1.value_as_number is null
	and o1.value_as_string is null
	and o1.value_as_concept_id is null
;
--}


--{815 IN (@list_of_analysis_ids)}?{
-- 815  Distribution of numeric values, by observation_concept_id and unit_concept_id
select observation_concept_id as subject_id, 
	unit_concept_id,
	CAST(value_as_number AS FLOAT) as count_value
INTO #rawData_815
from @cdm_database_schema.observation o1
where o1.unit_concept_id is not null
	and o1.value_as_number is not null
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    unit_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_815
	group by subject_id, unit_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, unit_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, unit_concept_id order by count_value) as rn
  FROM #rawData_815
  group by subject_id, unit_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 815 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_815;
drop table #rawData_815;

truncate table #tempResults;
drop table #tempResults;

--}


--{816 IN (@list_of_analysis_ids)}?{
-- 816	Distribution of low range, by observation_concept_id and unit_concept_id

--NOT APPLICABLE FOR OMOP CDM v5

--}


--{817 IN (@list_of_analysis_ids)}?{
-- 817	Distribution of high range, by observation_concept_id and unit_concept_id

--NOT APPLICABLE FOR OMOP CDM v5

--}



--{818 IN (@list_of_analysis_ids)}?{
-- 818	Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id

--NOT APPLICABLE FOR OMOP CDM v5

--}



--{820 IN (@list_of_analysis_ids)}?{
-- 820	Number of observation records by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 820 as analysis_id,   
	CAST(YEAR(observation_date)*100 + month(observation_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.observation o1
group by YEAR(observation_date)*100 + month(observation_date)
;
--}



--{891 IN (@list_of_analysis_ids)}?{
-- 891	Number of total persons that have at least x observations
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 
	891 as analysis_id,
	CAST(observation_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(obs_cnt AS VARCHAR(255)) as stratum_2,
	sum(count(person_id))	over (partition by observation_concept_id order by obs_cnt desc) as count_value
from (
	select 
		o.observation_concept_id, 
		count(o.observation_id) as obs_cnt, 
		o.person_id
	from @cdm_database_schema.observation o 
	group by o.person_id, o.observation_concept_id
) cnt_q
group by cnt_q.observation_concept_id, cnt_q.obs_cnt;
--}



/********************************************

ACHILLES Analyses on DRUG_ERA table

*********************************************/


--{900 IN (@list_of_analysis_ids)}?{
-- 900	Number of persons with at least one drug occurrence, by drug_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 900 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_era de1
group by de1.drug_CONCEPT_ID
;
--}


--{901 IN (@list_of_analysis_ids)}?{
-- 901	Number of drug occurrence records, by drug_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 901 as analysis_id, 
	CAST(de1.drug_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_era de1
group by de1.drug_CONCEPT_ID
;
--}



--{902 IN (@list_of_analysis_ids)}?{
-- 902	Number of persons by drug occurrence start month, by drug_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 902 as analysis_id,   
	CAST(de1.drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(drug_era_start_date)*100 + month(drug_era_start_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.drug_era de1
group by de1.drug_concept_id, 
	YEAR(drug_era_start_date)*100 + month(drug_era_start_date)
;
--}



--{903 IN (@list_of_analysis_ids)}?{
-- 903	Number of distinct drug era concepts per person
with rawData(count_value) as
(
  select COUNT_BIG(distinct de1.drug_concept_id) as count_value
	from @cdm_database_schema.drug_era de1
	group by de1.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 903 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}



--{904 IN (@list_of_analysis_ids)}?{
-- 904	Number of persons with at least one drug occurrence, by drug_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 904 as analysis_id,   
	CAST(de1.drug_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(drug_era_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(drug_era_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.drug_era de1
on p1.person_id = de1.person_id
group by de1.drug_concept_id, 
	YEAR(drug_era_start_date),
	p1.gender_concept_id,
	floor((year(drug_era_start_date) - p1.year_of_birth)/10)
;
--}




--{906 IN (@list_of_analysis_ids)}?{
-- 906	Distribution of age by drug_concept_id
select de.drug_concept_id as subject_id,
  p1.gender_concept_id,
  de.drug_start_year - p1.year_of_birth as count_value
INTO #rawData_906
from @cdm_database_schema.PERSON p1
inner join
(
	select person_id, drug_concept_id, min(year(drug_era_start_date)) as drug_start_year
	from @cdm_database_schema.drug_era
	group by person_id, drug_concept_id
) de on p1.person_id =de.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_906
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_906
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 906 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;


truncate table #rawData_906;
drop table #rawData_906;

truncate table #tempResults;
drop table #tempResults;
--}


--{907 IN (@list_of_analysis_ids)}?{
-- 907	Distribution of drug era length, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select drug_concept_id,
    datediff(dd,drug_era_start_date, drug_era_end_date) as count_value
  from  @cdm_database_schema.drug_era de1
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
  	CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
		count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 907 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}



--{908 IN (@list_of_analysis_ids)}?{
-- 908	Number of drug eras with invalid person
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 908 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_era de1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = de1.person_id
where p1.person_id is null
;
--}


--{909 IN (@list_of_analysis_ids)}?{
-- 909	Number of drug eras outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 909 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_era de1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = de1.person_id
	and de1.drug_era_start_date >= op1.observation_period_start_date
	and de1.drug_era_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{910 IN (@list_of_analysis_ids)}?{
-- 910	Number of drug eras with end date < start date
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 910 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	@cdm_database_schema.drug_era de1
where de1.drug_era_end_date < de1.drug_era_start_date
;
--}



--{920 IN (@list_of_analysis_ids)}?{
-- 920	Number of drug era records by drug era start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 920 as analysis_id,   
	CAST(YEAR(drug_era_start_date)*100 + month(drug_era_start_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.drug_era de1
group by YEAR(drug_era_start_date)*100 + month(drug_era_start_date)
;
--}





/********************************************

ACHILLES Analyses on CONDITION_ERA table

*********************************************/


--{1000 IN (@list_of_analysis_ids)}?{
-- 1000	Number of persons with at least one condition occurrence, by condition_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1000 as analysis_id, 
	CAST(ce1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct ce1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_era ce1
group by ce1.condition_CONCEPT_ID
;
--}


--{1001 IN (@list_of_analysis_ids)}?{
-- 1001	Number of condition occurrence records, by condition_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1001 as analysis_id, 
	CAST(ce1.condition_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_era ce1
group by ce1.condition_CONCEPT_ID
;
--}



--{1002 IN (@list_of_analysis_ids)}?{
-- 1002	Number of persons by condition occurrence start month, by condition_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 1002 as analysis_id,   
	CAST(ce1.condition_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(condition_era_start_date)*100 + month(condition_era_start_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
@cdm_database_schema.condition_era ce1
group by ce1.condition_concept_id, 
	YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
;
--}



--{1003 IN (@list_of_analysis_ids)}?{
-- 1003	Number of distinct condition era concepts per person
with rawData(count_value) as
(
  select COUNT_BIG(distinct ce1.condition_concept_id) as count_value
	from @cdm_database_schema.condition_era ce1
	group by ce1.person_id
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 1003 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}



--{1004 IN (@list_of_analysis_ids)}?{
-- 1004	Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 1004 as analysis_id,   
	CAST(ce1.condition_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(condition_era_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(condition_era_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join
@cdm_database_schema.condition_era ce1
on p1.person_id = ce1.person_id
group by ce1.condition_concept_id, 
	YEAR(condition_era_start_date),
	p1.gender_concept_id,
	floor((year(condition_era_start_date) - p1.year_of_birth)/10)
;
--}




--{1006 IN (@list_of_analysis_ids)}?{
-- 1006	Distribution of age by condition_concept_id
select ce.condition_concept_id as subject_id,
  p1.gender_concept_id,
  ce.condition_start_year - p1.year_of_birth as count_value
INTO #rawData_1006
from @cdm_database_schema.PERSON p1
inner join
(
  select person_id, condition_concept_id, min(year(condition_era_start_date)) as condition_start_year
  from @cdm_database_schema.condition_era
  group by person_id, condition_concept_id
) ce on p1.person_id = ce.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_1006
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_1006
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 1006 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_1006;
drop table #rawData_1006;

truncate table #tempResults;
drop table #tempResults;

--}



--{1007 IN (@list_of_analysis_ids)}?{
-- 1007	Distribution of condition era length, by condition_concept_id
with rawData(stratum1_id, count_value) as
(
  select condition_concept_id as stratum1_id,
    datediff(dd,condition_era_start_date, condition_era_end_date) as count_value
  from  @cdm_database_schema.condition_era ce1
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
		count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1007 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}



--{1008 IN (@list_of_analysis_ids)}?{
-- 1008	Number of condition eras with invalid person
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1008 as analysis_id,  
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_era ce1
	left join @cdm_database_schema.PERSON p1
	on p1.person_id = ce1.person_id
where p1.person_id is null
;
--}


--{1009 IN (@list_of_analysis_ids)}?{
-- 1009	Number of condition eras outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1009 as analysis_id,  
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_era ce1
	left join @cdm_database_schema.observation_period op1
	on op1.person_id = ce1.person_id
	and ce1.condition_era_start_date >= op1.observation_period_start_date
	and ce1.condition_era_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{1010 IN (@list_of_analysis_ids)}?{
-- 1010	Number of condition eras with end date < start date
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1010 as analysis_id,  
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	@cdm_database_schema.condition_era ce1
where ce1.condition_era_end_date < ce1.condition_era_start_date
;
--}


--{1020 IN (@list_of_analysis_ids)}?{
-- 1020	Number of drug era records by drug era start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1020 as analysis_id,   
	CAST(YEAR(condition_era_start_date)*100 + month(condition_era_start_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
@cdm_database_schema.condition_era ce1
group by YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
;
--}




/********************************************

ACHILLES Analyses on LOCATION table

*********************************************/

--{1100 IN (@list_of_analysis_ids)}?{
-- 1100	Number of persons by location 3-digit zip
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1100 as analysis_id,  
	CAST(left(l1.zip,3) AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join @cdm_database_schema.LOCATION l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.zip is not null
group by left(l1.zip,3);
--}


--{1101 IN (@list_of_analysis_ids)}?{
-- 1101	Number of persons by location state
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1101 as analysis_id,  
	CAST(l1.state AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join @cdm_database_schema.LOCATION l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.state is not null
group by l1.state;
--}


--{1102 IN (@list_of_analysis_ids)}?{
-- 1102	Number of care sites by location 3-digit zip
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1102 as analysis_id,  
	CAST(left(l1.zip,3) AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct care_site_id) as count_value
from @cdm_database_schema.care_site cs1
	inner join @cdm_database_schema.LOCATION l1
	on cs1.location_id = l1.location_id
where cs1.location_id is not null
	and l1.zip is not null
group by left(l1.zip,3);
--}


--{1103 IN (@list_of_analysis_ids)}?{
-- 1103	Number of care sites by location state
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1103 as analysis_id,  
	CAST(l1.state AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct care_site_id) as count_value
from @cdm_database_schema.care_site cs1
	inner join @cdm_database_schema.LOCATION l1
	on cs1.location_id = l1.location_id
where cs1.location_id is not null
	and l1.state is not null
group by l1.state;
--}


/********************************************

ACHILLES Analyses on CARE_SITE table

*********************************************/


--{1200 IN (@list_of_analysis_ids)}?{
-- 1200	Number of persons by place of service
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1200 as analysis_id,  
	CAST(cs1.place_of_service_concept_id AS VARCHAR(255)) as stratum_1, COUNT_BIG(person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join @cdm_database_schema.care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;
--}


--{1201 IN (@list_of_analysis_ids)}?{
-- 1201	Number of visits by place of service
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1201 as analysis_id,  
	CAST(cs1.place_of_service_concept_id AS VARCHAR(255)) as stratum_1, COUNT_BIG(visit_occurrence_id) as count_value
from @cdm_database_schema.visit_occurrence vo1
	inner join @cdm_database_schema.care_site cs1
	on vo1.care_site_id = cs1.care_site_id
where vo1.care_site_id is not null
	and cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;
--}


--{1202 IN (@list_of_analysis_ids)}?{
-- 1202	Number of care sites by place of service
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1202 as analysis_id,  
	CAST(cs1.place_of_service_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(care_site_id) as count_value
from @cdm_database_schema.care_site cs1
where cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;
--}


/********************************************

ACHILLES Analyses on ORGANIZATION table

*********************************************/

--{1300 IN (@list_of_analysis_ids)}?{
-- 1300	Number of organizations by place of service

--NOT APPLICABLE IN CDMv5

--}





/********************************************

ACHILLES Analyses on PAYOR_PLAN_PERIOD table

*********************************************/


--{1406 IN (@list_of_analysis_ids)}?{
-- 1406	Length of payer plan (days) of first payer plan period by gender
with rawData(stratum1_id, count_value) as
(
  select p1.gender_concept_id as stratum1_id,
    DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date) as count_value
  from @cdm_database_schema.PERSON p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from @cdm_database_schema.payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
  	count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1406 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}



--{1407 IN (@list_of_analysis_ids)}?{
-- 1407	Length of payer plan (days) of first payer plan period by age decile
with rawData(stratum_id, count_value) as
(
  select floor((year(ppp1.payer_plan_period_START_DATE) - p1.YEAR_OF_BIRTH)/10) as stratum_id,
    DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date) as count_value
  from @cdm_database_schema.PERSON p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from @cdm_database_schema.payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
),
overallStats (stratum_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM rawData
  group by stratum_id
),
statsView (stratum_id, count_value, total, rn) as
(
  select stratum_id, count_value, count_big(*) as total, row_number() over (order by count_value) as rn
  FROM rawData
  group by stratum_id, count_value
),
priorStats (stratum_id, count_value, total, accumulated) as
(
  select s.stratum_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum_id = p.stratum_id and p.rn <= s.rn
  group by s.stratum_id, s.count_value, s.total, s.rn
)
select 1407 as analysis_id,
  CAST(o.stratum_id AS VARCHAR(255)) AS stratum_id,
  o.total as count_value,
  o.min_value,
  o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum_id = o.stratum_id
GROUP BY o.stratum_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}




--{1408 IN (@list_of_analysis_ids)}?{
-- 1408	Number of persons by length of payer plan period, in 30d increments
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1408 as analysis_id,  
	CAST(floor(DATEDIFF(dd, ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)/30) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct p1.person_id) as count_value
from @cdm_database_schema.PERSON p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from @cdm_database_schema.payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
group by CAST(floor(DATEDIFF(dd, ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)/30) AS VARCHAR(255))
;
--}


--{1409 IN (@list_of_analysis_ids)}?{
-- 1409	Number of persons with continuous payer plan in each year
-- Note: using temp table instead of nested query because this gives vastly improved

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

select distinct 
  YEAR(payer_plan_period_start_date) as obs_year 
INTO
  #temp_dates
from 
  @cdm_database_schema.payer_plan_period
;

insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1409 as analysis_id,  
	CAST(t1.obs_year AS VARCHAR(255)) as stratum_1, COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join 
    @cdm_database_schema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates t1 
where year(ppp1.payer_plan_period_START_DATE) <= t1.obs_year
	and year(ppp1.payer_plan_period_END_DATE) >= t1.obs_year
group by t1.obs_year
;

truncate table #temp_dates;
drop table #temp_dates;
--}


--{1410 IN (@list_of_analysis_ids)}?{
-- 1410	Number of persons with continuous payer plan in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

IF OBJECT_ID('tempdb..#temp_dates', 'U') IS NOT NULL
	DROP TABLE #temp_dates;

SELECT DISTINCT 
  YEAR(payer_plan_period_start_date)*100 + MONTH(payer_plan_period_start_date) AS obs_month,
  DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_start_date), 1)  AS obs_month_start,
  EOMONTH(payer_plan_period_start_date) AS obs_month_end
INTO
  #temp_dates
FROM 
  @cdm_database_schema.payer_plan_period
;

insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 
  1410 as analysis_id, 
	CAST(obs_month AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join 
  @cdm_database_schema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates
where ppp1.payer_plan_period_START_DATE <= obs_month_start
	and ppp1.payer_plan_period_END_DATE >= obs_month_end
group by obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;
--}



--{1411 IN (@list_of_analysis_ids)}?{
-- 1411	Number of persons by payer plan period start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1411 as analysis_id, 
	DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_START_DATE), 1) AS stratum_1,
	 COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join @cdm_database_schema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
group by DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_START_DATE), 1)
;
--}



--{1412 IN (@list_of_analysis_ids)}?{
-- 1412	Number of persons by payer plan period end month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1412 as analysis_id,  
	DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_START_DATE), 1) AS stratum_1,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join @cdm_database_schema.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
group by DATEFROMPARTS(YEAR(payer_plan_period_start_date), MONTH(payer_plan_period_START_DATE), 1)
;
--}


--{1413 IN (@list_of_analysis_ids)}?{
-- 1413	Number of persons by number of payer plan periods
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1413 as analysis_id,  
	CAST(ppp1.num_periods AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join (select person_id, COUNT_BIG(payer_plan_period_start_date) as num_periods from @cdm_database_schema.payer_plan_period group by PERSON_ID) ppp1
	on p1.person_id = ppp1.person_id
group by ppp1.num_periods
;
--}

--{1414 IN (@list_of_analysis_ids)}?{
-- 1414	Number of persons with payer plan period before year-of-birth
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1414 as analysis_id,  
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@cdm_database_schema.PERSON p1
	inner join (select person_id, MIN(year(payer_plan_period_start_date)) as first_obs_year from @cdm_database_schema.payer_plan_period group by PERSON_ID) ppp1
	on p1.person_id = ppp1.person_id
where p1.year_of_birth > ppp1.first_obs_year
;
--}

--{1415 IN (@list_of_analysis_ids)}?{
-- 1415	Number of persons with payer plan period end < start
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1415 as analysis_id,  
	COUNT_BIG(ppp1.PERSON_ID) as count_value
from
	@cdm_database_schema.payer_plan_period ppp1
where ppp1.payer_plan_period_end_date < ppp1.payer_plan_period_start_date
;
--}

{ @runCostAnalysis }?{

/********************************************

ACHILLES Analyses on DRUG_COST table

*********************************************/

-- for performance optimization, we create a table with drug costs pre-cached for the 15XX analysis


-- {1502 in (@list_of_analysis_ids) | 1503 in (@list_of_analysis_ids) | 1504 in (@list_of_analysis_ids) | 1505 in (@list_of_analysis_ids) | 1506 in (@list_of_analysis_ids) | 1507 in (@list_of_analysis_ids) | 1508 in (@list_of_analysis_ids) | 1509 in (@list_of_analysis_ids) | 1510 in (@list_of_analysis_ids) | 1511 in (@list_of_analysis_ids)}?{

IF OBJECT_ID('@results_database_schema.ACHILLES_drug_cost_raw', 'U') IS NOT NULL
  DROP TABLE @results_database_schema.ACHILLES_drug_cost_raw;

select drug_concept_id as subject_id,
  paid_copay,
	paid_coinsurance,
	paid_toward_deductible,
	paid_by_payer,
	paid_by_coordination_benefits, 
	total_out_of_pocket,
	total_paid,
	ingredient_cost,
	dispensing_fee,
	average_wholesale_price
INTO @results_database_schema.ACHILLES_drug_cost_raw
from @cdm_database_schema.drug_cost dc1
join @cdm_database_schema.drug_exposure de1 on de1.drug_exposure_id = dc1.drug_exposure_id and drug_concept_id <> 0
;
--}



--{1500 IN (@list_of_analysis_ids)}?{
-- 1500	Number of drug cost records with invalid drug exposure id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1500 as analysis_id,  
	COUNT_BIG(dc1.drug_cost_ID) as count_value
from
	@cdm_database_schema.drug_cost dc1
		left join @cdm_database_schema.drug_exposure de1
		on dc1.drug_exposure_id = de1.drug_exposure_id
where de1.drug_exposure_id is null
;
--}

--{1501 IN (@list_of_analysis_ids)}?{
-- 1501	Number of drug cost records with invalid payer plan period id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1501 as analysis_id,  
	COUNT_BIG(dc1.drug_cost_ID) as count_value
from
	@cdm_database_schema.drug_cost dc1
		left join @cdm_database_schema.payer_plan_period ppp1
		on dc1.payer_plan_period_id = ppp1.payer_plan_period_id
where dc1.payer_plan_period_id is not null
	and ppp1.payer_plan_period_id is null
;
--}


--{1502 IN (@list_of_analysis_ids)}?{
-- 1502	Distribution of paid copay, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_copay as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where paid_copay is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
		count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1502 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}


--{1503 IN (@list_of_analysis_ids)}?{
-- 1503	Distribution of paid coinsurance, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_coinsurance as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where paid_coinsurance is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
		count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1503 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}

--{1504 IN (@list_of_analysis_ids)}?{
-- 1504	Distribution of paid toward deductible, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_toward_deductible as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where paid_toward_deductible is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
  	count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1504 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}

--{1505 IN (@list_of_analysis_ids)}?{
-- 1505	Distribution of paid by payer, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_by_payer as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where paid_by_payer is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
  	count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1505 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}

--{1506 IN (@list_of_analysis_ids)}?{
-- 1506	Distribution of paid by coordination of benefit, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_by_coordination_benefits as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where paid_by_coordination_benefits is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
		row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1506 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{1507 IN (@list_of_analysis_ids)}?{
-- 1507	Distribution of total out-of-pocket, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    total_out_of_pocket as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where total_out_of_pocket is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
  	row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1507 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{1508 IN (@list_of_analysis_ids)}?{
-- 1508	Distribution of total paid, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    total_paid as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where total_paid is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1508 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{1509 IN (@list_of_analysis_ids)}?{
-- 1509	Distribution of ingredient_cost, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    ingredient_cost as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where ingredient_cost is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1509 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{1510 IN (@list_of_analysis_ids)}?{
-- 1510	Distribution of dispensing fee, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    dispensing_fee as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where dispensing_fee is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1510 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;
--}

--{1511 IN (@list_of_analysis_ids)}?{
-- 1511	Distribution of average wholesale price, by drug_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    average_wholesale_price as count_value
  from @results_database_schema.ACHILLES_drug_cost_raw
  where average_wholesale_price is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1511 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;


--}

{1502 in (@list_of_analysis_ids) | 1503 in (@list_of_analysis_ids) | 1504 in (@list_of_analysis_ids) | 1505 in (@list_of_analysis_ids) | 1506 in (@list_of_analysis_ids) | 1507 in (@list_of_analysis_ids) | 1508 in (@list_of_analysis_ids) | 1509 in (@list_of_analysis_ids) | 1510 in (@list_of_analysis_ids) | 1511 in (@list_of_analysis_ids)}?{
-- clean up cached table
DROP TABLE @results_database_schema.ACHILLES_drug_cost_raw;
}

/********************************************

ACHILLES Analyses on PROCEDURE_COST table

*********************************************/

{(1602 in (@list_of_analysis_ids) | 1603 in (@list_of_analysis_ids) | 1604 in (@list_of_analysis_ids) | 1605 in (@list_of_analysis_ids) | 1606 in (@list_of_analysis_ids) | 1607 in (@list_of_analysis_ids) | 1608 in (@list_of_analysis_ids))}?{

IF OBJECT_ID('@results_database_schema.ACHILLES_procedure_cost_raw', 'U') IS NOT NULL
  DROP TABLE @results_database_schema.ACHILLES_procedure_cost_raw;

select procedure_concept_id as subject_id,
  paid_copay,
  paid_coinsurance,
	paid_toward_deductible,
	paid_by_payer,
	paid_by_coordination_benefits, 
	total_out_of_pocket,
	total_paid
INTO @results_database_schema.ACHILLES_procedure_cost_raw
from @cdm_database_schema.procedure_cost pc1
join @cdm_database_schema.procedure_occurrence po1 on pc1.procedure_occurrence_id = po1.procedure_occurrence_id and procedure_concept_id <> 0
;
}


--{1600 IN (@list_of_analysis_ids)}?{
-- 1600	Number of procedure cost records with invalid procedure exposure id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1600 as analysis_id,  
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	@cdm_database_schema.procedure_cost pc1
		left join @cdm_database_schema.procedure_occurrence po1
		on pc1.procedure_occurrence_id = po1.procedure_occurrence_id
where po1.procedure_occurrence_id is null
;
--}

--{1601 IN (@list_of_analysis_ids)}?{
-- 1601	Number of procedure cost records with invalid payer plan period id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1601 as analysis_id,  
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	@cdm_database_schema.procedure_cost pc1
		left join @cdm_database_schema.payer_plan_period ppp1
		on pc1.payer_plan_period_id = ppp1.payer_plan_period_id
where pc1.payer_plan_period_id is not null
	and ppp1.payer_plan_period_id is null
;
--}


--{1602 IN (@list_of_analysis_ids)}?{
-- 1602	Distribution of paid copay, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_copay as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where paid_copay is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1602 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{1603 IN (@list_of_analysis_ids)}?{
-- 1603	Distribution of paid coinsurance, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_coinsurance as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where paid_coinsurance is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1603 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
  MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{1604 IN (@list_of_analysis_ids)}?{
-- 1604	Distribution of paid toward deductible, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_toward_deductible as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where paid_toward_deductible is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1604 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
  MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
  MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{1605 IN (@list_of_analysis_ids)}?{
-- 1605	Distribution of paid by payer, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_by_payer as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where paid_by_payer is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1605 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
  MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
  MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
  MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{1606 IN (@list_of_analysis_ids)}?{
-- 1606	Distribution of paid by coordination of benefit, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    paid_by_coordination_benefits as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where paid_by_coordination_benefits is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1606 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
  MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
  MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
  MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
  MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}

--{1607 IN (@list_of_analysis_ids)}?{
-- 1607	Distribution of total out-of-pocket, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    total_out_of_pocket as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where total_out_of_pocket is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1607 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
  MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
  MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
  MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
  MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;

--}


--{1608 IN (@list_of_analysis_ids)}?{
-- 1608	Distribution of total paid, by procedure_concept_id
with rawData(stratum1_id, count_value) as
(
  select subject_id as stratum1_id,
    total_paid as count_value
  from @results_database_schema.ACHILLES_procedure_cost_raw
  where total_paid is not null
),
overallStats (stratum1_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select stratum1_id, 
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
  group by stratum1_id
),
statsView (stratum1_id, count_value, total, rn) as
(
  select stratum1_id, 
    count_value, 
    count_big(*) as total, 
    row_number() over (partition by stratum1_id order by count_value) as rn
  FROM rawData
  group by stratum1_id, count_value
),
priorStats (stratum1_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and p.rn <= s.rn
  group by s.stratum1_id, s.count_value, s.total, s.rn
)
select 1608 as analysis_id,
  CAST(p.stratum1_id AS VARCHAR(255)) as stratum_1,
  o.total as count_value,
  o.min_value,
  o.max_value,
  o.avg_value,
  o.stdev_value,
  MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
  MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
  MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
  MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
  MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id
GROUP BY p.stratum1_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;
drop table #tempResults;
--}


--{1609 IN (@list_of_analysis_ids)}?{
-- 1609	Number of records by disease_class_concept_id

--not applicable for OMOP CDMv5

--}


--{1610 IN (@list_of_analysis_ids)}?{
-- 1610	Number of records by revenue_code_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1610 as analysis_id, 
	CAST(revenue_code_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	@cdm_database_schema.procedure_cost pc1
where revenue_code_concept_id is not null
group by revenue_code_concept_id
;
--}

{(1602 in (@list_of_analysis_ids) | 1603 in (@list_of_analysis_ids) | 1604 in (@list_of_analysis_ids) | 1605 in (@list_of_analysis_ids) | 1606 in (@list_of_analysis_ids) | 1607 in (@list_of_analysis_ids) | 1608 in (@list_of_analysis_ids))}?{
-- clean up cached table
DROP TABLE @results_database_schema.ACHILLES_procedure_cost_raw;
}

-- End Cost Analysis
}

/********************************************

ACHILLES Analyses on COHORT table

*********************************************/


--{1700 IN (@list_of_analysis_ids)}?{
-- 1700	Number of records by cohort_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1700 as analysis_id, 
	CAST(cohort_definition_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(subject_ID) as count_value
from
	@cdm_database_schema.cohort c1
group by cohort_definition_id
;
--}


--{1701 IN (@list_of_analysis_ids)}?{
-- 1701	Number of records with cohort end date < cohort start date
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1701 as analysis_id, 
	COUNT_BIG(subject_ID) as count_value
from
	@cdm_database_schema.cohort c1
where c1.cohort_end_date < c1.cohort_start_date
;
--}

/********************************************

ACHILLES Analyses on MEASUREMENT table

*********************************************/



--{1800 IN (@list_of_analysis_ids)}?{
-- 1800	Number of persons with at least one measurement occurrence, by measurement_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1800 as analysis_id, 
	CAST(m.measurement_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct m.PERSON_ID) as count_value
from
	@cdm_database_schema.measurement m
group by m.measurement_CONCEPT_ID
;
--}


--{1801 IN (@list_of_analysis_ids)}?{
-- 1801	Number of measurement occurrence records, by measurement_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1801 as analysis_id, 
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(m.PERSON_ID) as count_value
from
	@cdm_database_schema.measurement m
group by m.measurement_CONCEPT_ID
;
--}



--{1802 IN (@list_of_analysis_ids)}?{
-- 1802	Number of persons by measurement occurrence start month, by measurement_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 1802 as analysis_id,   
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(measurement_date)*100 + month(measurement_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
	@cdm_database_schema.measurement m
group by m.measurement_concept_id, 
	YEAR(measurement_date)*100 + month(measurement_date)
;
--}



--{1803 IN (@list_of_analysis_ids)}?{
-- 1803	Number of distinct measurement occurrence concepts per person
with rawData(count_value) as
(
  select num_measurements as count_value
  from
	(
  	select m.person_id, COUNT_BIG(distinct m.measurement_concept_id) as num_measurements
  	from
  	@cdm_database_schema.measurement m
  	group by m.person_id
	) t0
),
overallStats (avg_value, stdev_value, min_value, max_value, total) as
(
  select CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  from rawData
),
statsView (count_value, total, rn) as
(
  select count_value, 
  	count_big(*) as total, 
		row_number() over (order by count_value) as rn
  FROM rawData
  group by count_value
),
priorStats (count_value, total, accumulated) as
(
  select s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on p.rn <= s.rn
  group by s.count_value, s.total, s.rn
)
select 1803 as analysis_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
CROSS JOIN overallStats o
GROUP BY o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #tempResults;

drop table #tempResults;


--}



--{1804 IN (@list_of_analysis_ids)}?{
-- 1804	Number of persons with at least one measurement occurrence, by measurement_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 1804 as analysis_id,   
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(measurement_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(measurement_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join @cdm_database_schema.measurement m on p1.person_id = m.person_id
group by m.measurement_concept_id, 
	YEAR(measurement_date),
	p1.gender_concept_id,
	floor((year(measurement_date) - p1.year_of_birth)/10)
;
--}

--{1805 IN (@list_of_analysis_ids)}?{
-- 1805	Number of measurement records, by measurement_concept_id by measurement_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 1805 as analysis_id, 
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(m.measurement_type_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
group by m.measurement_concept_id,	
	m.measurement_type_concept_id
;
--}



--{1806 IN (@list_of_analysis_ids)}?{
-- 1806	Distribution of age by measurement_concept_id
select o1.measurement_concept_id as subject_id,
  p1.gender_concept_id,
	o1.measurement_start_year - p1.year_of_birth as count_value
INTO #rawData_1806
from @cdm_database_schema.PERSON p1
inner join
(
	select person_id, measurement_concept_id, min(year(measurement_date)) as measurement_start_year
	from @cdm_database_schema.measurement
	group by person_id, measurement_concept_id
) o1
on p1.person_id = o1.person_id
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    gender_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_1806
	group by subject_id, gender_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, gender_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, gender_concept_id order by count_value) as rn
  FROM #rawData_1806
  group by subject_id, gender_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 1806 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_1806;
drop table #rawData_1806;

truncate table #tempResults;
drop table #tempResults;


--}

--{1807 IN (@list_of_analysis_ids)}?{
-- 1807	Number of measurement occurrence records, by measurement_concept_id and unit_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 1807 as analysis_id, 
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(m.unit_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
group by m.measurement_concept_id, m.unit_concept_id
;
--}



--{1809 IN (@list_of_analysis_ids)}?{
-- 1809	Number of measurement records with invalid person_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1809 as analysis_id,  
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
	left join @cdm_database_schema.PERSON p1 on p1.person_id = m.person_id
where p1.person_id is null
;
--}


--{1810 IN (@list_of_analysis_ids)}?{
-- 1810	Number of measurement records outside valid observation period
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1810 as analysis_id,  
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
	left join @cdm_database_schema.observation_period op on op.person_id = m.person_id
	and m.measurement_date >= op.observation_period_start_date
	and m.measurement_date <= op.observation_period_end_date
where op.person_id is null
;
--}



--{1812 IN (@list_of_analysis_ids)}?{
-- 1812	Number of measurement records with invalid provider_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1812 as analysis_id,  
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
	left join @cdm_database_schema.provider p on p.provider_id = m.provider_id
where m.provider_id is not null
	and p.provider_id is null
;
--}

--{1813 IN (@list_of_analysis_ids)}?{
-- 1813	Number of observation records with invalid visit_id
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1813 as analysis_id, COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
	left join @cdm_database_schema.visit_occurrence vo on m.visit_occurrence_id = vo.visit_occurrence_id
where m.visit_occurrence_id is not null
	and vo.visit_occurrence_id is null
;
--}


--{1814 IN (@list_of_analysis_ids)}?{
-- 1814	Number of measurement records with no value (numeric or concept)
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1814 as analysis_id,  
	COUNT_BIG(m.PERSON_ID) as count_value
from
	@cdm_database_schema.measurement m
where m.value_as_number is null
	and m.value_as_concept_id is null
;
--}


--{1815 IN (@list_of_analysis_ids)}?{
-- 1815  Distribution of numeric values, by measurement_concept_id and unit_concept_id
select measurement_concept_id as subject_id, 
	unit_concept_id,
	CAST(value_as_number AS FLOAT) as count_value
INTO #rawData_1815
from @cdm_database_schema.measurement m
where m.unit_concept_id is not null
	and m.value_as_number is not null
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    unit_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_1815
	group by subject_id, unit_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, unit_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, unit_concept_id order by count_value) as rn
  FROM #rawData_1815
  group by subject_id, unit_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 1815 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_1815;
drop table #rawData_1815;

truncate table #tempResults;
drop table #tempResults;

--}


--{1816 IN (@list_of_analysis_ids)}?{
-- 1816	Distribution of low range, by measurement_concept_id and unit_concept_id
select measurement_concept_id as subject_id, 
	unit_concept_id,
	CAST(range_low AS FLOAT) as count_value
INTO #rawData_1816
from @cdm_database_schema.measurement m
where m.unit_concept_id is not null
	and m.value_as_number is not null
	and m.range_low is not null
	and m.range_high is not null
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    unit_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_1816
	group by subject_id, unit_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, unit_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, unit_concept_id order by count_value) as rn
  FROM #rawData_1816
  group by subject_id, unit_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 1816 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_1816;
drop table #rawData_1816;

truncate table #tempResults;
drop table #tempResults;

--}


--{1817 IN (@list_of_analysis_ids)}?{
-- 1817	Distribution of high range, by observation_concept_id and unit_concept_id
select measurement_concept_id as subject_id, 
	unit_concept_id,
	CAST(range_high AS FLOAT) as count_value
INTO #rawData_1817
from @cdm_database_schema.measurement m
where m.unit_concept_id is not null
	and m.value_as_number is not null
	and m.range_low is not null
	and m.range_high is not null
;

with overallStats (stratum1_id, stratum2_id, avg_value, stdev_value, min_value, max_value, total) as
(
  select subject_id as stratum1_id,
    unit_concept_id as stratum2_id,
    CAST(avg(1.0 * count_value) AS FLOAT) as avg_value,
    CAST(stdev(count_value) AS FLOAT) as stdev_value,
    min(count_value) as min_value,
    max(count_value) as max_value,
    count_big(*) as total
  FROM #rawData_1817
	group by subject_id, unit_concept_id
),
statsView (stratum1_id, stratum2_id, count_value, total, rn) as
(
  select subject_id as stratum1_id, unit_concept_id as stratum2_id, count_value, count_big(*) as total, row_number() over (partition by subject_id, unit_concept_id order by count_value) as rn
  FROM #rawData_1817
  group by subject_id, unit_concept_id, count_value
),
priorStats (stratum1_id, stratum2_id, count_value, total, accumulated) as
(
  select s.stratum1_id, s.stratum2_id, s.count_value, s.total, sum(p.total) as accumulated
  from statsView s
  join statsView p on s.stratum1_id = p.stratum1_id and s.stratum2_id = p.stratum2_id and p.rn <= s.rn
  group by s.stratum1_id, s.stratum2_id, s.count_value, s.total, s.rn
)
select 1817 as analysis_id,
  CAST(o.stratum1_id AS VARCHAR(255)) AS stratum1_id,
  CAST(o.stratum2_id AS VARCHAR(255)) AS stratum2_id,
  o.total as count_value,
  o.min_value,
	o.max_value,
	o.avg_value,
	o.stdev_value,
	MIN(case when p.accumulated >= .50 * o.total then count_value else o.max_value end) as median_value,
	MIN(case when p.accumulated >= .10 * o.total then count_value else o.max_value end) as p10_value,
	MIN(case when p.accumulated >= .25 * o.total then count_value else o.max_value end) as p25_value,
	MIN(case when p.accumulated >= .75 * o.total then count_value else o.max_value end) as p75_value,
	MIN(case when p.accumulated >= .90 * o.total then count_value else o.max_value end) as p90_value
into #tempResults
from priorStats p
join overallStats o on p.stratum1_id = o.stratum1_id and p.stratum2_id = o.stratum2_id 
GROUP BY o.stratum1_id, o.stratum2_id, o.total, o.min_value, o.max_value, o.avg_value, o.stdev_value
;

insert into @results_database_schema.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select analysis_id, stratum1_id, stratum2_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value
from #tempResults
;

truncate table #rawData_1817;
drop table #rawData_1817;

truncate table #tempResults;
drop table #tempResults;

--}



--{1818 IN (@list_of_analysis_ids)}?{
-- 1818	Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 1818 as analysis_id,  
	CAST(m.measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(m.unit_concept_id AS VARCHAR(255)) as stratum_2,
	CAST(case when m.value_as_number < m.range_low then 'Below Range Low'
		when m.value_as_number >= m.range_low and m.value_as_number <= m.range_high then 'Within Range'
		when m.value_as_number > m.range_high then 'Above Range High'
		else 'Other' end AS VARCHAR(255)) as stratum_3,
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.measurement m
where m.value_as_number is not null
	and m.unit_concept_id is not null
	and m.range_low is not null
	and m.range_high is not null
group by measurement_concept_id,
	unit_concept_id,
	  CAST(case when m.value_as_number < m.range_low then 'Below Range Low'
		when m.value_as_number >= m.range_low and m.value_as_number <= m.range_high then 'Within Range'
		when m.value_as_number > m.range_high then 'Above Range High'
		else 'Other' end AS VARCHAR(255))
;
--}




--{1820 IN (@list_of_analysis_ids)}?{
-- 1820	Number of observation records by condition occurrence start month
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1820 as analysis_id,   
	CAST(YEAR(measurement_date)*100 + month(measurement_date) AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from @cdm_database_schema.measurement m
group by YEAR(measurement_date)*100 + month(measurement_date)
;
--}

--{1821 IN (@list_of_analysis_ids)}?{
-- 1821	Number of measurement records with no numeric value
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 1821 as analysis_id,  
	COUNT_BIG(m.PERSON_ID) as count_value
from
	@cdm_database_schema.measurement m
where m.value_as_number is null
;
--}


--{1891 IN (@list_of_analysis_ids)}?{
-- 1891	Number of total persons that have at least x measurements
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 
	1891 as analysis_id,
	CAST(measurement_concept_id AS VARCHAR(255)) as stratum_1,
	CAST(meas_cnt AS VARCHAR(255)) as stratum_2,
	sum(count(person_id))	over (partition by measurement_concept_id order by meas_cnt desc) as count_value
from (
	select 
		m.measurement_concept_id, 
		count(m.measurement_id) as meas_cnt, 
		m.person_id
	from @cdm_database_schema.measurement m 
	group by m.person_id, m.measurement_concept_id
) cnt_q
group by cnt_q.measurement_concept_id, cnt_q.meas_cnt;
--}
--end of measurement analyses

/********************************************

Reports 

*********************************************/


--{1900 IN (@list_of_analysis_ids)}?{
-- 1900	concept_0 report

INSERT INTO @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 1900 as analysis_id, CAST(table_name AS VARCHAR(255)) as stratum_1, source_value as stratum_2, cnt as count_value
 from (
select 'measurement' as table_name,measurement_source_value as source_value, COUNT_BIG(*) as cnt from @cdm_database_schema.measurement where measurement_concept_id = 0 group by measurement_source_value 
union
select 'procedure_occurrence' as table_name,procedure_source_value as source_value, COUNT_BIG(*) as cnt from @cdm_database_schema.procedure_occurrence where procedure_concept_id = 0 group by procedure_source_value 
union
select 'drug_exposure' as table_name,drug_source_value as source_value, COUNT_BIG(*) as cnt from @cdm_database_schema.drug_exposure where drug_concept_id = 0 group by drug_source_value 
union
select 'condition_occurrence' as table_name,condition_source_value as source_value, COUNT_BIG(*) as cnt from @cdm_database_schema.condition_occurrence where condition_concept_id = 0 group by condition_source_value 
) a
where cnt >= 1 --use other threshold if needed (e.g., 10)
--order by a.table_name desc, cnt desc
;
--}


/********************************************

ACHILLES Iris Analyses 

*********************************************/
--starting at id 2000

--{2000 IN (@list_of_analysis_ids)}?{
-- 2000	patients with at least 1 Dx and 1 Rx
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 2000 as analysis_id,  
--gender_concept_id as stratum_1, COUNT_BIG(distinct person_id) as count_value
        CAST(a.cnt AS BIGINT) AS count_value
    FROM (
                select COUNT_BIG(*) cnt from (
                    select distinct person_id from @cdm_database_schema.condition_occurrence
                    intersect
                    select distinct person_id from @cdm_database_schema.drug_exposure
                ) b
         ) a
         ;
--}



--{2001 IN (@list_of_analysis_ids)}?{
-- 2001	patients with at least 1 Dx and 1 Proc
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 2001 as analysis_id,  
--gender_concept_id as stratum_1, COUNT_BIG(distinct person_id) as count_value
        CAST(a.cnt AS BIGINT) AS count_value
    FROM (
                select COUNT_BIG(*) cnt from (
                    select distinct person_id from @cdm_database_schema.condition_occurrence
                    intersect
                    select distinct person_id from @cdm_database_schema.procedure_occurrence
                ) b
         ) a
         ;
--}



--{2002 IN (@list_of_analysis_ids)}?{
-- 2002	patients with at least 1 Mes and 1 Dx and 1 Rx
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 2002 as analysis_id,  
--gender_concept_id as stratum_1, COUNT_BIG(distinct person_id) as count_value
        CAST(a.cnt AS BIGINT) AS count_value
    FROM (
                select COUNT_BIG(*) cnt from (
                    select distinct person_id from @cdm_database_schema.measurement
                    intersect
                    select distinct person_id from @cdm_database_schema.condition_occurrence
                    intersect
                    select distinct person_id from @cdm_database_schema.drug_exposure
                ) b
         ) a
         ;
--}


--{2003 IN (@list_of_analysis_ids)}?{
-- 2003	Patients with at least one visit
-- this analysis is in fact redundant, since it is possible to get it via
-- dist analysis 203 and query select count_value from achilles_results_dist where analysis_id = 203;
insert into @results_database_schema.ACHILLES_results (analysis_id, count_value)
select 2003 as analysis_id,  COUNT_BIG(distinct person_id) as count_value
from @cdm_database_schema.visit_occurrence;
--}


/********************************************

ACHILLES Analyses on DEVICE_EXPOSURE  table

*********************************************/



--{2100 IN (@list_of_analysis_ids)}?{
-- 2100	Number of persons with at least one device exposure , by device_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 2100 as analysis_id, 
	CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct m.PERSON_ID) as count_value
from
	@cdm_database_schema.device_exposure m
group by m.device_CONCEPT_ID
;
--}


--{2101 IN (@list_of_analysis_ids)}?{
-- 2101	Number of device exposure  records, by device_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 2101 as analysis_id, 
    CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(m.PERSON_ID) as count_value
from
	@cdm_database_schema.device_exposure m
group by m.device_CONCEPT_ID
;
--}



--{2102 IN (@list_of_analysis_ids)}?{
-- 2102	Number of persons by device by  start month, by device_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 2102 as analysis_id,   
	CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(device_exposure_start_date)*100 + month(device_exposure_start_date) AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(distinct PERSON_ID) as count_value
from
	@cdm_database_schema.device_exposure m
group by m.device_CONCEPT_ID, 
	YEAR(device_exposure_start_date)*100 + month(device_exposure_start_date)
;
--}

--2103 is not implemented at this point


--{2104 IN (@list_of_analysis_ids)}?{
-- 2104	Number of persons with at least one device occurrence, by device_concept_id by calendar year by gender by age decile
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 2104 as analysis_id,   
	CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(YEAR(device_exposure_start_date) AS VARCHAR(255)) as stratum_2,
	CAST(p1.gender_concept_id AS VARCHAR(255)) as stratum_3,
	CAST(floor((year(device_exposure_start_date) - p1.year_of_birth)/10) AS VARCHAR(255)) as stratum_4,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from @cdm_database_schema.PERSON p1
inner join @cdm_database_schema.device_exposure m on p1.person_id = m.person_id
group by m.device_CONCEPT_ID, 
	YEAR(device_exposure_start_date),
	p1.gender_concept_id,
	floor((year(device_exposure_start_date) - p1.year_of_birth)/10)
;
--}


--{2105 IN (@list_of_analysis_ids)}?{
-- 2105	Number of exposure records by device_concept_id by device_type_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 2105 as analysis_id, 
	CAST(m.device_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	CAST(m.device_type_concept_id AS VARCHAR(255)) as stratum_2,
	COUNT_BIG(m.PERSON_ID) as count_value
from @cdm_database_schema.device_exposure m
group by m.device_CONCEPT_ID,	
	m.device_type_concept_id
;
--}

--2106 and more analyses are not implemented at this point





/********************************************

ACHILLES Analyses on NOTE table

*********************************************/



--{2200 IN (@list_of_analysis_ids)}?{
-- 2200	Number of persons with at least one device exposure , by device_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 2200 as analysis_id, 
	CAST(m.note_type_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(distinct m.PERSON_ID) as count_value
from
	@cdm_database_schema.note m
group by m.note_type_CONCEPT_ID
;
--}


--{2201 IN (@list_of_analysis_ids)}?{
-- 2201	Number of device exposure  records, by device_concept_id
insert into @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 2201 as analysis_id, 
    CAST(m.note_type_CONCEPT_ID AS VARCHAR(255)) as stratum_1,
	COUNT_BIG(m.PERSON_ID) as count_value
from
	@cdm_database_schema.note m
group by m.note_type_CONCEPT_ID
;
--}





--final processing of results
delete from @results_database_schema.ACHILLES_results 
where count_value <= @smallcellcount;
delete from @results_database_schema.ACHILLES_results_dist 
where count_value <= @smallcellcount;

/******************************************************************

# @file ACHILLES_v5_init_clean_validate.SQL
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
part 1 init

*******************************************************************/

{DEFAULT @cdm_database = 'CDM'}
{DEFAULT @results_database = 'scratch'}
{DEFAULT @results_database_schema = 'scratch.dbo'}
{DEFAULT @source_name = 'CDM NAME'}
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

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (220, 'Number of visit occurrence records by visit occurrence start month', 'calendar month');



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
	values (1801, 'Number of measurement occurrence records, by observation_concept_id', 'measurement_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1802, 'Number of persons by measurement occurrence start month, by observation_concept_id', 'measurement_concept_id', 'calendar month');	

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
	values (1803, 'Number of distinct observation occurrence concepts per person');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (1804, 'Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile', 'measurement_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1805, 'Number of observation occurrence records, by measurement_concept_id by measurement_type_concept_id', 'measurement_concept_id', 'measurement_type_concept_id');

insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1806, 'Distribution of age by observation_concept_id', 'observation_concept_id', 'gender_concept_id');

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


--end of importing values into analysis lookup table

--} : {else if not createTable
delete from @results_database_schema.ACHILLES_results where analysis_id IN (@list_of_analysis_ids);
delete from @results_database_schema.ACHILLES_results_dist where analysis_id IN (@list_of_analysis_ids);
}

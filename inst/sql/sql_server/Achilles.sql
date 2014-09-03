/*****************
Achilles

Patrick Ryan
******************/

{DEFAULT @CDM_schema = 'CDM_TRUVEN_MDCD'}
{DEFAULT @results_schema = 'scratch'}
{DEFAULT @source_name = 'TRUVEN MDCD'}
{DEFAULT @smallcellcount = 5}
{DEFAULT @createTable = TRUE}

  /****
    developer comment about general ACHILLES calculation process:  
		you could drive # of persons by age decile, from # of persons by age decile by gender
		as a general rule:  do full stratification once, and then aggregate across strata to avoid re-calculation
		works for all prevalence calculations...does not work for any distribution statistics
	*****/

use @results_schema;
--use CDM_TRUVEN_MDCD;


--{@createTable}?{

IF OBJECT_ID('ACHILLES_analysis', 'U') IS NOT NULL
  drop table ACHILLES_analysis;

create table ACHILLES_analysis
(
	analysis_id int,
	analysis_name varchar(255),
	stratum_1_name varchar(255),
	stratum_2_name varchar(255),
	stratum_3_name varchar(255),
	stratum_4_name varchar(255),
	stratum_5_name varchar(255)
);


IF OBJECT_ID('ACHILLES_results', 'U') IS NOT NULL
  drop table ACHILLES_results;

create table ACHILLES_results
(
	analysis_id int,
	stratum_1 varchar(255),
	stratum_2 varchar(255),
	stratum_3 varchar(255),
	stratum_4 varchar(255),
	stratum_5 varchar(255),
	count_value bigint
);


IF OBJECT_ID('ACHILLES_results_dist', 'U') IS NOT NULL
  drop table ACHILLES_results_dist;

create table ACHILLES_results_dist
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





insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (0, 'Source name');

--000. PERSON statistics

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1, 'Number of persons');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (2, 'Number of persons by gender', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (3, 'Number of persons by year of birth', 'year_of_birth');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (4, 'Number of persons by race', 'race_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (5, 'Number of persons by ethnicity', 'ethnicity_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (7, 'Number of persons with invalid provider_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (8, 'Number of persons with invalid location_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (9, 'Number of persons with invalid care_site_id');


--100. OBSERVATION_PERIOD (joined to PERSON)

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (101, 'Number of persons by age, with age at first observation period', 'age');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (102, 'Number of persons by gender by age, with age at first observation period', 'gender_concept_id', 'age');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (103, 'Distribution of age at first observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (104, 'Distribution of age at first observation period by gender', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (105, 'Length of observation (days) of first observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (106, 'Length of observation (days) of first observation period by gender', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (107, 'Length of observation (days) of first observation period by age decile', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (108, 'Number of persons by length of observation period, in 30d increments', 'Observation period length 30d increments');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (109, 'Number of persons with continuous observation in each year', 'calendar year');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (110, 'Number of persons with continuous observation in each month', 'calendar month');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (111, 'Number of persons by observation period start month', 'calendar month');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (112, 'Number of persons by observation period end month', 'calendar month');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (113, 'Number of persons by number of observation periods', 'number of observation periods');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (114, 'Number of persons with observation period before year-of-birth');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (115, 'Number of persons with observation period end < observation period start');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name)
	values (116, 'Number of persons with at least one day of observation in each year by gender and age decile', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (117, 'Number of persons with at least one day of observation in each month', 'calendar month');



--200- VISIT_OCCURRENCE


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (200, 'Number of persons with at least one visit occurrence, by visit_concept_id', 'visit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (201, 'Number of visit occurrence records, by visit_concept_id', 'visit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (202, 'Number of persons by visit occurrence start month, by visit_concept_id', 'visit_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (203, 'Number of distinct visit occurrence concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (204, 'Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile', 'visit_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (206, 'Distribution of age by visit_concept_id', 'visit_concept_id', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (207, 'Number of visit records with invalid person_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (208, 'Number of visit records outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (209, 'Number of visit records with end date < start date');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (210, 'Number of visit records with invalid care_site_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (211, 'Distribution of length of stay by visit_concept_id', 'visit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (220, 'Number of visit occurrence records by visit occurrence start month', 'calendar month');



--300- PROVIDER
insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (300, 'Number of providers');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (301, 'Number of providers by specialty concept_id', 'specialty_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (302, 'Number of providers with invalid care site id');



--400- CONDITION_OCCURRENCE

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (400, 'Number of persons with at least one condition occurrence, by condition_concept_id', 'condition_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (401, 'Number of condition occurrence records, by condition_concept_id', 'condition_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (402, 'Number of persons by condition occurrence start month, by condition_concept_id', 'condition_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (403, 'Number of distinct condition occurrence concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (404, 'Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile', 'condition_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (405, 'Number of condition occurrence records, by condition_concept_id by condition_type_concept_id', 'condition_concept_id', 'condition_type_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (406, 'Distribution of age by condition_concept_id', 'condition_concept_id', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (409, 'Number of condition occurrence records with invalid person_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (410, 'Number of condition occurrence records outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (411, 'Number of condition occurrence records with end date < start date');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (412, 'Number of condition occurrence records with invalid provider_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (413, 'Number of condition occurrence records with invalid visit_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (420, 'Number of condition occurrence records by condition occurrence start month', 'calendar month');	

--500- DEATH

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (500, 'Number of persons with death, by cause_of_death_concept_id', 'cause_of_death_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (501, 'Number of records of death, by cause_of_death_concept_id', 'cause_of_death_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (502, 'Number of persons by death month', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name)
	values (504, 'Number of persons with a death, by calendar year by gender by age decile', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (505, 'Number of death records, by death_type_concept_id', 'death_type_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (506, 'Distribution of age at death by gender', 'gender_concept_id');


insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (509, 'Number of death records with invalid person_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (510, 'Number of death records outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (511, 'Distribution of time from death to last condition');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (512, 'Distribution of time from death to last drug');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (513, 'Distribution of time from death to last visit');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (514, 'Distribution of time from death to last procedure');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (515, 'Distribution of time from death to last observation');


--600- PROCEDURE_OCCURRENCE



insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (600, 'Number of persons with at least one procedure occurrence, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (601, 'Number of procedure occurrence records, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (602, 'Number of persons by procedure occurrence start month, by procedure_concept_id', 'procedure_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (603, 'Number of distinct procedure occurrence concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (604, 'Number of persons with at least one procedure occurrence, by procedure_concept_id by calendar year by gender by age decile', 'procedure_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (605, 'Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id', 'procedure_concept_id', 'procedure_type_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (606, 'Distribution of age by procedure_concept_id', 'procedure_concept_id', 'gender_concept_id');



insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (609, 'Number of procedure occurrence records with invalid person_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (610, 'Number of procedure occurrence records outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (612, 'Number of procedure occurrence records with invalid provider_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (613, 'Number of procedure occurrence records with invalid visit_id');


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (620, 'Number of procedure occurrence records  by procedure occurrence start month', 'calendar month');


--700- DRUG_EXPOSURE


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (700, 'Number of persons with at least one drug exposure, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (701, 'Number of drug exposure records, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (702, 'Number of persons by drug exposure start month, by drug_concept_id', 'drug_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (703, 'Number of distinct drug exposure concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (704, 'Number of persons with at least one drug exposure, by drug_concept_id by calendar year by gender by age decile', 'drug_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (705, 'Number of drug exposure records, by drug_concept_id by drug_type_concept_id', 'drug_concept_id', 'drug_type_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (706, 'Distribution of age by drug_concept_id', 'drug_concept_id', 'gender_concept_id');



insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (709, 'Number of drug exposure records with invalid person_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (710, 'Number of drug exposure records outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (711, 'Number of drug exposure records with end date < start date');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (712, 'Number of drug exposure records with invalid provider_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (713, 'Number of drug exposure records with invalid visit_id');



insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (715, 'Distribution of days_supply by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (716, 'Distribution of refills by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (717, 'Distribution of quantity by drug_concept_id', 'drug_concept_id');


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (720, 'Number of drug exposure records  by drug exposure start month', 'calendar month');


--800- OBSERVATION


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (800, 'Number of persons with at least one observation occurrence, by observation_concept_id', 'observation_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (801, 'Number of observation occurrence records, by observation_concept_id', 'observation_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (802, 'Number of persons by observation occurrence start month, by observation_concept_id', 'observation_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (803, 'Number of distinct observation occurrence concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (804, 'Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile', 'observation_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (805, 'Number of observation occurrence records, by observation_concept_id by observation_type_concept_id', 'observation_concept_id', 'observation_type_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (806, 'Distribution of age by observation_concept_id', 'observation_concept_id', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (807, 'Number of observation occurrence records, by observation_concept_id and unit_concept_id', 'observation_concept_id', 'unit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (809, 'Number of observation records with invalid person_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (810, 'Number of observation records outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (812, 'Number of observation records with invalid provider_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (813, 'Number of observation records with invalid visit_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (814, 'Number of observation records with no value (numeric, string, or concept)');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (815, 'Distribution of numeric values, by observation_concept_id and unit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (816, 'Distribution of low range, by observation_concept_id and unit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (817, 'Distribution of high range, by observation_concept_id and unit_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (818, 'Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id');


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (820, 'Number of observation records  by observation start month', 'calendar month');



--900- DRUG_ERA


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (900, 'Number of persons with at least one drug era, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (901, 'Number of drug era records, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (902, 'Number of persons by drug era start month, by drug_concept_id', 'drug_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (903, 'Number of distinct drug era concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (904, 'Number of persons with at least one drug era, by drug_concept_id by calendar year by gender by age decile', 'drug_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (906, 'Distribution of age by drug_concept_id', 'drug_concept_id', 'gender_concept_id');
	
insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (907, 'Distribution of drug era length, by drug_concept_id', 'drug_concept_id');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (908, 'Number of drug eras without valid person');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (909, 'Number of drug eras outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (910, 'Number of drug eras with end date < start date');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (920, 'Number of drug era records  by drug era start month', 'calendar month');

--1000- CONDITION_ERA


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1000, 'Number of persons with at least one condition era, by condition_concept_id', 'condition_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1001, 'Number of condition era records, by condition_concept_id', 'condition_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1002, 'Number of persons by condition era start month, by condition_concept_id', 'condition_concept_id', 'calendar month');	

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1003, 'Number of distinct condition era concepts per person');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name, stratum_3_name, stratum_4_name)
	values (1004, 'Number of persons with at least one condition era, by condition_concept_id by calendar year by gender by age decile', 'condition_concept_id', 'calendar year', 'gender_concept_id', 'age decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name, stratum_2_name)
	values (1006, 'Distribution of age by condition_concept_id', 'condition_concept_id', 'gender_concept_id');
	
insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1007, 'Distribution of condition era length, by condition_concept_id', 'condition_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1008, 'Number of condition eras without valid person');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1009, 'Number of condition eras outside valid observation period');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1010, 'Number of condition eras with end date < start date');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1020, 'Number of condition era records by condition era start month', 'calendar month');



--1100- LOCATION


insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1100, 'Number of persons by location 3-digit zip', '3-digit zip');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1101, 'Number of persons by location state', 'state');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1102, 'Number of care sites by location 3-digit zip', '3-digit zip');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1103, 'Number of care sites by location state', 'state');


--1200- CARE_SITE

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1200, 'Number of persons by place of service', 'place_of_service_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1201, 'Number of visits by place of service', 'place_of_service_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1202, 'Number of care sites by place of service', 'place_of_service_concept_id');


--1300- ORGANIZATION

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1300, 'Number of organizations by place of service', 'place_of_service_concept_id');


--1400- PAYOR_PLAN_PERIOD

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1406, 'Length of payer plan (days) of first payer plan period by gender', 'gender_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1407, 'Length of payer plan (days) of first payer plan period by age decile', 'age_decile');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1408, 'Number of persons by length of payer plan period, in 30d increments', 'payer plan period length 30d increments');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1409, 'Number of persons with continuous payer plan in each year', 'calendar year');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1410, 'Number of persons with continuous payer plan in each month', 'calendar month');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1411, 'Number of persons by payer plan period start month', 'calendar month');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1412, 'Number of persons by payer plan period end month', 'calendar month');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1413, 'Number of persons by number of payer plan periods', 'number of payer plan periods');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1414, 'Number of persons with payer plan period before year-of-birth');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1415, 'Number of persons with payer plan period end < payer plan period start');

--1500- DRUG_COST



insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1500, 'Number of drug cost records with invalid drug exposure id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1501, 'Number of drug cost records with invalid payer plan period id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1502, 'Distribution of paid copay, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1503, 'Distribution of paid coinsurance, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1504, 'Distribution of paid toward deductible, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1505, 'Distribution of paid by payer, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1506, 'Distribution of paid by coordination of benefit, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1507, 'Distribution of total out-of-pocket, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1508, 'Distribution of total paid, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1509, 'Distribution of ingredient_cost, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1510, 'Distribution of dispensing fee, by drug_concept_id', 'drug_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1511, 'Distribution of average wholesale price, by drug_concept_id', 'drug_concept_id');


--1600- PROCEDURE_COST



insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1600, 'Number of procedure cost records with invalid procedure occurrence id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1601, 'Number of procedure cost records with invalid payer plan period id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1602, 'Distribution of paid copay, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1603, 'Distribution of paid coinsurance, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1604, 'Distribution of paid toward deductible, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1605, 'Distribution of paid by payer, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1606, 'Distribution of paid by coordination of benefit, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1607, 'Distribution of total out-of-pocket, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1608, 'Distribution of total paid, by procedure_concept_id', 'procedure_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1609, 'Number of records by disease_class_concept_id', 'disease_class_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1610, 'Number of records by revenue_code_concept_id', 'revenue_code_concept_id');


--1700- COHORT

insert into ACHILLES_analysis (analysis_id, analysis_name, stratum_1_name)
	values (1700, 'Number of records by cohort_concept_id', 'cohort_concept_id');

insert into ACHILLES_analysis (analysis_id, analysis_name)
	values (1701, 'Number of records with cohort end date < cohort start date');

--} : {else if not createTable
delete from @results_schema.dbo.ACHILLES_results where analysis_id IN (@list_of_analysis_ids);
delete from @results_schema.dbo.ACHILLES_results_dist where analysis_id IN (@list_of_analysis_ids);
}

/****
7. generate results for analysis_results


****/

use @CDM_schema;


--{0 IN (@list_of_analysis_ids)}?{
-- 0	Number of persons
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 0 as analysis_id,  '@source_name' as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON;

insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value)
select 0 as analysis_id, '@source_name' as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON;

--}


/********************************************

ACHILLES Analyses on PERSON table

*********************************************/

--{1 IN (@list_of_analysis_ids)}?{
-- 1	Number of persons
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1 as analysis_id,  COUNT_BIG(distinct person_id) as count_value
from PERSON;
--}


--{2 IN (@list_of_analysis_ids)}?{
-- 2	Number of persons by gender
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 2 as analysis_id,  gender_concept_id as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON
group by GENDER_CONCEPT_ID;
--}



--{3 IN (@list_of_analysis_ids)}?{
-- 3	Number of persons by year of birth
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 3 as analysis_id,  year_of_birth as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON
group by YEAR_OF_BIRTH;
--}


--{4 IN (@list_of_analysis_ids)}?{
-- 4	Number of persons by race
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 4 as analysis_id,  RACE_CONCEPT_ID as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON
group by RACE_CONCEPT_ID;
--}



--{5 IN (@list_of_analysis_ids)}?{
-- 5	Number of persons by ethnicity
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 5 as analysis_id,  ETHNICITY_CONCEPT_ID as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON
group by ETHNICITY_CONCEPT_ID;
--}





--{7 IN (@list_of_analysis_ids)}?{
-- 7	Number of persons with invalid provider_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 7 as analysis_id,  COUNT_BIG(p1.person_id) as count_value
from PERSON p1
	left join provider pr1
	on p1.provider_id = pr1.provider_id
where p1.provider_id is not null
	and pr1.provider_id is null
;
--}



--{8 IN (@list_of_analysis_ids)}?{
-- 8	Number of persons with invalid location_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 8 as analysis_id,  COUNT_BIG(p1.person_id) as count_value
from PERSON p1
	left join location l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.location_id is null
;
--}


--{9 IN (@list_of_analysis_ids)}?{
-- 9	Number of persons with invalid care_site_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 9 as analysis_id,  COUNT_BIG(p1.person_id) as count_value
from PERSON p1
	left join care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.care_site_id is null
;
--}







/********************************************

ACHILLES Analyses on OBSERVATION_PERIOD table

*********************************************/

--{101 IN (@list_of_analysis_ids)}?{
-- 101	Number of persons by age, with age at first observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 101 as analysis_id,   year(op1.index_date) - p1.YEAR_OF_BIRTH as stratum_1, COUNT_BIG(p1.person_id) as count_value
from PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by year(op1.index_date) - p1.YEAR_OF_BIRTH;
--}



--{102 IN (@list_of_analysis_ids)}?{
-- 102	Number of persons by gender by age, with age at first observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 102 as analysis_id,  p1.gender_concept_id as stratum_1, year(op1.index_date) - p1.YEAR_OF_BIRTH as stratum_2, COUNT_BIG(p1.person_id) as count_value
from PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
group by p1.gender_concept_id, year(op1.index_date) - p1.YEAR_OF_BIRTH;
--}


--{103 IN (@list_of_analysis_ids)}?{
-- 103	Distribution of age at first observation period
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 103 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select year(op1.index_date) - p1.YEAR_OF_BIRTH as count_value,
	1.0*(row_number() over (order by year(op1.index_date) - p1.YEAR_OF_BIRTH))/(COUNT_BIG(year(op1.index_date) - p1.YEAR_OF_BIRTH) over ()+1) as p1
from
	PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
) t1
;
--}




--{104 IN (@list_of_analysis_ids)}?{
-- 104	Distribution of age at first observation period by gender
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 104 as analysis_id,
	gender_concept_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select p1.gender_concept_id,
	year(op1.index_date) - p1.YEAR_OF_BIRTH as count_value,
	1.0*(row_number() over (partition by p1.gender_concept_id order by year(op1.index_date) - p1.YEAR_OF_BIRTH))/(COUNT_BIG(year(op1.index_date) - p1.YEAR_OF_BIRTH) over (partition by p1.gender_concept_id)+1) as p1
from
	PERSON p1
	inner join (select person_id, MIN(observation_period_start_date) as index_date from OBSERVATION_PERIOD group by PERSON_ID) op1
	on p1.PERSON_ID = op1.PERSON_ID
) t1
group by gender_concept_id
;
--}




--{105 IN (@list_of_analysis_ids)}?{
-- 105	Length of observation (days) of first observation period
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 105 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date) as count_value,
	1.0*(row_number() over (order by DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date)))/(COUNT_BIG(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date)) over ()+1) as p1
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
;
--}


--{106 IN (@list_of_analysis_ids)}?{
-- 106	Length of observation (days) of first observation period by gender
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 106 as analysis_id,
	gender_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select p1.gender_concept_id,
	DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date) as count_value,
	1.0*(row_number() over (partition by p1.gender_concept_id order by DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date)))/(COUNT_BIG(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date)) over (partition by p1.gender_concept_id)+1) as p1
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
group by gender_concept_id
;
--}



--{107 IN (@list_of_analysis_ids)}?{
-- 107	Length of observation (days) of first observation period by age decile
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 107 as analysis_id,
	age_decile as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select floor((year(op1.OBSERVATION_PERIOD_START_DATE) - p1.YEAR_OF_BIRTH)/10) as age_decile,
	DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date) as count_value,
	1.0*(row_number() over (partition by floor((year(op1.OBSERVATION_PERIOD_START_DATE) - p1.YEAR_OF_BIRTH)/10) order by DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date)))/(COUNT_BIG(DATEDIFF(dd,op1.observation_period_start_date, op1.observation_period_end_date)) over (partition by floor((year(op1.OBSERVATION_PERIOD_START_DATE) - p1.YEAR_OF_BIRTH)/10))+1) as p1
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
group by age_decile
;
--}






--{108 IN (@list_of_analysis_ids)}?{
-- 108	Number of persons by length of observation period, in 30d increments
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 108 as analysis_id,  floor(DATEDIFF(dd, op1.observation_period_start_date, op1.observation_period_end_date)/30) as stratum_1, COUNT_BIG(distinct p1.person_id) as count_value
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
--}




--{109 IN (@list_of_analysis_ids)}?{
-- 109	Number of persons with continuous observation in each year
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

USE @results_schema; --Set to result schema so temp tables are created where user has write rights (Oracle)

IF OBJECT_ID('temp_dates', 'U') IS NOT NULL --This should only do something in Oracle
  drop table temp_dates;

SELECT DISTINCT 
  YEAR(observation_period_start_date) AS obs_year,
  CAST(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)) +  '01' + '01' AS DATE) AS obs_year_start,	
  CAST(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)) +  '12' + '31' AS DATE) AS obs_year_end
INTO
  #temp_dates
FROM 
  @CDM_schema.dbo.observation_period
;

INSERT INTO ACHILLES_results (analysis_id, stratum_1, count_value)
SELECT 
  109 AS analysis_id,  
	obs_year AS stratum_1, 
	COUNT_BIG(DISTINCT person_id) AS count_value
FROM 
	@CDM_schema.dbo.observation_period,
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

USE @CDM_schema;
--}


--{110 IN (@list_of_analysis_ids)}?{
-- 110	Number of persons with continuous observation in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

USE @results_schema; --Set to result schema so temp tables are created where user has write rights (Oracle)

IF OBJECT_ID('temp_dates', 'U') IS NOT NULL --This should only do something in Oracle
  drop table temp_dates;

SELECT DISTINCT 
  YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) AS obs_month,
  CAST(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)) +  RIGHT('0' + CAST(MONTH(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2)), 2) + '01' AS DATE) AS obs_month_start,  
  DATEADD(dd,-1,DATEADD(mm,1,CAST(CAST(YEAR(observation_period_start_date) AS VARCHAR(4)) +  RIGHT('0' + CAST(MONTH(OBSERVATION_PERIOD_START_DATE) AS VARCHAR(2)), 2) + '01' AS DATE))) AS obs_month_end
INTO
  #temp_dates
FROM 
  @CDM_schema.dbo.observation_period
;


INSERT INTO ACHILLES_results (analysis_id, stratum_1, count_value)
SELECT 
  110 AS analysis_id, 
	obs_month AS stratum_1, 
	COUNT_BIG(DISTINCT person_id) AS count_value
FROM
	@CDM_schema.dbo.observation_period,
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

USE @CDM_schema;
--}



--{111 IN (@list_of_analysis_ids)}?{
-- 111	Number of persons by observation period start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 111 as analysis_id, 
	YEAR(observation_period_start_date)*100 + month(OBSERVATION_PERIOD_START_DATE) as stratum_1, 
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	observation_period op1
group by YEAR(observation_period_start_date)*100 + month(OBSERVATION_PERIOD_START_DATE)
;
--}



--{112 IN (@list_of_analysis_ids)}?{
-- 112	Number of persons by observation period end month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 112 as analysis_id,  
	YEAR(observation_period_end_date)*100 + month(observation_period_end_date) as stratum_1, 
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	observation_period op1
group by YEAR(observation_period_end_date)*100 + month(observation_period_end_date)
;
--}


--{113 IN (@list_of_analysis_ids)}?{
-- 113	Number of persons by number of observation periods
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 113 as analysis_id,  
	op1.num_periods as stratum_1, COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	(select person_id, COUNT_BIG(OBSERVATION_period_start_date) as num_periods from observation_period group by PERSON_ID) op1
group by op1.num_periods
;
--}

--{114 IN (@list_of_analysis_ids)}?{
-- 114	Number of persons with observation period before year-of-birth
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 114 as analysis_id,  
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	PERSON p1
	inner join (select person_id, MIN(year(OBSERVATION_period_start_date)) as first_obs_year from observation_period group by PERSON_ID) op1
	on p1.person_id = op1.person_id
where p1.year_of_birth > op1.first_obs_year
;
--}

--{115 IN (@list_of_analysis_ids)}?{
-- 115	Number of persons with observation period end < start
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 115 as analysis_id,  
	COUNT_BIG(op1.PERSON_ID) as count_value
from
	observation_period op1
where op1.observation_period_end_date < op1.observation_period_start_date
;
--}



--{116 IN (@list_of_analysis_ids)}?{
-- 116	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

USE @results_schema; --Set to result schema so temp tables are created where user has write rights (Oracle)

IF OBJECT_ID('temp_dates', 'U') IS NOT NULL --This should only do something in Oracle
  drop table temp_dates;

select distinct 
  YEAR(observation_period_start_date) as obs_year 
INTO
  #temp_dates
from 
  @CDM_schema.dbo.OBSERVATION_PERIOD
;

insert into ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 116 as analysis_id,  
	t1.obs_year as stratum_1, 
	p1.gender_concept_id as stratum_2,
	floor((t1.obs_year - p1.year_of_birth)/10) as stratum_3,
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@CDM_schema.dbo.PERSON p1
	inner join 
  @CDM_schema.dbo.observation_period op1
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

USE @CDM_schema;
--}


--{117 IN (@list_of_analysis_ids)}?{
-- 117	Number of persons with at least one day of observation in each year by gender and age decile
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

USE @results_schema; --Set to result schema so temp tables are created where user has write rights (Oracle)

IF OBJECT_ID('temp_dates', 'U') IS NOT NULL --This should only do something in Oracle
  drop table temp_dates;

select distinct 
  YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date)  as obs_month
into 
  #temp_dates
from 
  @CDM_schema.dbo.OBSERVATION_PERIOD
;

insert into ACHILLES_results (analysis_id, stratum_1, count_value)
select 117 as analysis_id,  
	t1.obs_month as stratum_1,
	COUNT_BIG(distinct op1.PERSON_ID) as count_value
from
	@CDM_schema.dbo.observation_period op1,
	#temp_dates t1 
where YEAR(observation_period_start_date)*100 + MONTH(observation_period_start_date) <= t1.obs_month
	and YEAR(observation_period_end_date)*100 + MONTH(observation_period_end_date) >= t1.obs_month
group by t1.obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

USE @CDM_schema;
--}


/********************************************

ACHILLES Analyses on VISIT_OCCURRENCE table

*********************************************/


--{200 IN (@list_of_analysis_ids)}?{
-- 200	Number of persons with at least one visit occurrence, by visit_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 200 as analysis_id, 
	vo1.place_of_service_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct vo1.PERSON_ID) as count_value
from
	visit_occurrence vo1
group by vo1.place_of_service_CONCEPT_ID
;
--}


--{201 IN (@list_of_analysis_ids)}?{
-- 201	Number of visit occurrence records, by visit_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 201 as analysis_id, 
	vo1.place_of_service_CONCEPT_ID as stratum_1,
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	visit_occurrence vo1
group by vo1.place_of_service_CONCEPT_ID
;
--}



--{202 IN (@list_of_analysis_ids)}?{
-- 202	Number of persons by visit occurrence start month, by visit_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 202 as analysis_id,   
	vo1.place_of_service_concept_id as stratum_1,
	YEAR(visit_start_date)*100 + month(visit_start_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
visit_occurrence vo1
group by vo1.place_of_service_concept_id, 
	YEAR(visit_start_date)*100 + month(visit_start_date)
;
--}



--{203 IN (@list_of_analysis_ids)}?{
-- 203	Number of distinct visit occurrence concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 203 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_visits as count_value,
	1.0*(row_number() over (order by num_visits))/(COUNT_BIG(num_visits) over ()+1) as p1
from
	(
	select vo1.person_id, COUNT_BIG(distinct vo1.place_of_service_concept_id) as num_visits
	from
	visit_occurrence vo1
	group by vo1.person_id
	) t0
) t1
;
--}



--{204 IN (@list_of_analysis_ids)}?{
-- 204	Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 204 as analysis_id,   
	vo1.place_of_service_concept_id as stratum_1,
	YEAR(visit_start_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(visit_start_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
visit_occurrence vo1
on p1.person_id = vo1.person_id
group by vo1.place_of_service_concept_id, 
	YEAR(visit_start_date),
	p1.gender_concept_id,
	floor((year(visit_start_date) - p1.year_of_birth)/10)
;
--}





--{206 IN (@list_of_analysis_ids)}?{
-- 206	Distribution of age by visit_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 206 as analysis_id,
	place_of_service_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select vo1.place_of_service_concept_id,
	p1.gender_concept_id,
	vo1.visit_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by vo1.place_of_service_concept_id, p1.gender_concept_id order by vo1.visit_start_year - p1.year_of_birth))/(COUNT_BIG(vo1.visit_start_year - p1.year_of_birth) over (partition by vo1.place_of_service_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, place_of_service_concept_id, min(year(visit_start_date)) as visit_start_year
from visit_occurrence
group by person_id, place_of_service_concept_id
) vo1
on p1.person_id = vo1.person_id
) t1
group by place_of_service_concept_id, gender_concept_id
;
--}


--{207 IN (@list_of_analysis_ids)}?{
--207	Number of visit records with invalid person_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 207 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	visit_occurrence vo1
	left join PERSON p1
	on p1.person_id = vo1.person_id
where p1.person_id is null
;
--}


--{208 IN (@list_of_analysis_ids)}?{
--208	Number of visit records outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 208 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	visit_occurrence vo1
	left join observation_period op1
	on op1.person_id = vo1.person_id
	and vo1.visit_start_date >= op1.observation_period_start_date
	and vo1.visit_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}

--{209 IN (@list_of_analysis_ids)}?{
--209	Number of visit records with end date < start date
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 209 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	visit_occurrence vo1
where visit_end_date < visit_start_date
;
--}

--{210 IN (@list_of_analysis_ids)}?{
--210	Number of visit records with invalid care_site_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 210 as analysis_id,  
	COUNT_BIG(vo1.PERSON_ID) as count_value
from
	visit_occurrence vo1
	left join care_site cs1
	on vo1.care_site_id = cs1.care_site_id
where vo1.care_site_id is not null
	and cs1.care_site_id is null
;
--}


--{211 IN (@list_of_analysis_ids)}?{
-- 211	Distribution of length of stay by visit_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 211 as analysis_id,
	place_of_service_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select vo1.place_of_service_concept_id,
	datediff(dd,visit_start_date,visit_end_date) as count_value,
	1.0*(row_number() over (partition by vo1.place_of_service_concept_id order by datediff(dd,visit_start_date,visit_end_date)))/(COUNT_BIG(datediff(dd,visit_start_date,visit_end_date)) over (partition by vo1.place_of_service_concept_id)+1) as p1
from visit_occurrence vo1
) t1
group by place_of_service_concept_id
;
--}


--{220 IN (@list_of_analysis_ids)}?{
-- 220	Number of visit occurrence records by condition occurrence start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 220 as analysis_id,   
	YEAR(visit_start_date)*100 + month(visit_start_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
visit_occurrence vo1
group by YEAR(visit_start_date)*100 + month(visit_start_date)
;
--}

/********************************************

ACHILLES Analyses on PROVIDER table

*********************************************/


--{300 IN (@list_of_analysis_ids)}?{
-- 300	Number of providers
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 300 as analysis_id,  COUNT_BIG(distinct provider_id) as count_value
from provider;
--}


--{301 IN (@list_of_analysis_ids)}?{
-- 301	Number of providers by specialty concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 301 as analysis_id,  specialty_concept_id as stratum_1, COUNT_BIG(distinct provider_id) as count_value
from provider
group by specialty_CONCEPT_ID;
--}

--{302 IN (@list_of_analysis_ids)}?{
-- 302	Number of providers with invalid care site id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 302 as analysis_id,  COUNT_BIG(provider_id) as count_value
from provider p1
	left join care_site cs1
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
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 400 as analysis_id, 
	co1.condition_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct co1.PERSON_ID) as count_value
from
	condition_occurrence co1
group by co1.condition_CONCEPT_ID
;
--}


--{401 IN (@list_of_analysis_ids)}?{
-- 401	Number of condition occurrence records, by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 401 as analysis_id, 
	co1.condition_CONCEPT_ID as stratum_1,
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
group by co1.condition_CONCEPT_ID
;
--}



--{402 IN (@list_of_analysis_ids)}?{
-- 402	Number of persons by condition occurrence start month, by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 402 as analysis_id,   
	co1.condition_concept_id as stratum_1,
	YEAR(condition_start_date)*100 + month(condition_start_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
condition_occurrence co1
group by co1.condition_concept_id, 
	YEAR(condition_start_date)*100 + month(condition_start_date)
;
--}



--{403 IN (@list_of_analysis_ids)}?{
-- 403	Number of distinct condition occurrence concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 403 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_conditions as count_value,
	1.0*(row_number() over (order by num_conditions))/(COUNT_BIG(num_conditions) over ()+1) as p1
from
	(
	select co1.person_id, COUNT_BIG(distinct co1.condition_concept_id) as num_conditions
	from
	condition_occurrence co1
	group by co1.person_id
	) t0
) t1
;
--}



--{404 IN (@list_of_analysis_ids)}?{
-- 404	Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 404 as analysis_id,   
	co1.condition_concept_id as stratum_1,
	YEAR(condition_start_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(condition_start_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
condition_occurrence co1
on p1.person_id = co1.person_id
group by co1.condition_concept_id, 
	YEAR(condition_start_date),
	p1.gender_concept_id,
	floor((year(condition_start_date) - p1.year_of_birth)/10)
;
--}

--{405 IN (@list_of_analysis_ids)}?{
-- 405	Number of condition occurrence records, by condition_concept_id by condition_type_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 405 as analysis_id, 
	co1.condition_CONCEPT_ID as stratum_1,
	co1.condition_type_concept_id as stratum_2,
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
group by co1.condition_CONCEPT_ID,	
	co1.condition_type_concept_id
;
--}



--{406 IN (@list_of_analysis_ids)}?{
-- 406	Distribution of age by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 406 as analysis_id,
	condition_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select co1.condition_concept_id,
	p1.gender_concept_id,
	co1.condition_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by co1.condition_concept_id, p1.gender_concept_id order by co1.condition_start_year - p1.year_of_birth))/(COUNT_BIG(co1.condition_start_year - p1.year_of_birth) over (partition by co1.condition_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, condition_concept_id, min(year(condition_start_date)) as condition_start_year
from condition_occurrence
group by person_id, condition_concept_id
) co1
on p1.person_id = co1.person_id
) t1
group by condition_concept_id, gender_concept_id
;
--}






--{409 IN (@list_of_analysis_ids)}?{
-- 409	Number of condition occurrence records with invalid person_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 409 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
	left join PERSON p1
	on p1.person_id = co1.person_id
where p1.person_id is null
;
--}


--{410 IN (@list_of_analysis_ids)}?{
-- 410	Number of condition occurrence records outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 410 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
	left join observation_period op1
	on op1.person_id = co1.person_id
	and co1.condition_start_date >= op1.observation_period_start_date
	and co1.condition_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{411 IN (@list_of_analysis_ids)}?{
-- 411	Number of condition occurrence records with end date < start date
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 411 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
where co1.condition_end_date < co1.condition_start_date
;
--}


--{412 IN (@list_of_analysis_ids)}?{
-- 412	Number of condition occurrence records with invalid provider_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 412 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
	left join provider p1
	on p1.provider_id = co1.associated_provider_id
where co1.associated_provider_id is not null
	and p1.provider_id is null
;
--}

--{413 IN (@list_of_analysis_ids)}?{
-- 413	Number of condition occurrence records with invalid visit_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 413 as analysis_id,  
	COUNT_BIG(co1.PERSON_ID) as count_value
from
	condition_occurrence co1
	left join visit_occurrence vo1
	on co1.visit_occurrence_id = vo1.visit_occurrence_id
where co1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}

--{420 IN (@list_of_analysis_ids)}?{
-- 420	Number of condition occurrence records by condition occurrence start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 420 as analysis_id,   
	YEAR(condition_start_date)*100 + month(condition_start_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
condition_occurrence co1
group by YEAR(condition_start_date)*100 + month(condition_start_date)
;
--}



/********************************************

ACHILLES Analyses on DEATH table

*********************************************/



--{500 IN (@list_of_analysis_ids)}?{
-- 500	Number of persons with death, by cause_of_death_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 500 as analysis_id, 
	d1.cause_of_death_concept_id as stratum_1,
	COUNT_BIG(distinct d1.PERSON_ID) as count_value
from
	death d1
group by d1.cause_of_death_CONCEPT_ID
;
--}


--{501 IN (@list_of_analysis_ids)}?{
-- 501	Number of records of death, by cause_of_death_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 501 as analysis_id, 
	d1.cause_of_death_concept_id as stratum_1,
	COUNT_BIG(d1.PERSON_ID) as count_value
from
	death d1
group by d1.cause_of_death_CONCEPT_ID
;
--}



--{502 IN (@list_of_analysis_ids)}?{
-- 502	Number of persons by condition occurrence start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 502 as analysis_id,   
	YEAR(death_date)*100 + month(death_date) as stratum_1, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
death d1
group by YEAR(death_date)*100 + month(death_date)
;
--}



--{504 IN (@list_of_analysis_ids)}?{
-- 504	Number of persons with a death, by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 504 as analysis_id,   
	YEAR(death_date) as stratum_1,
	p1.gender_concept_id as stratum_2,
	floor((year(death_date) - p1.year_of_birth)/10) as stratum_3, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
death d1
on p1.person_id = d1.person_id
group by YEAR(death_date),
	p1.gender_concept_id,
	floor((year(death_date) - p1.year_of_birth)/10)
;
--}

--{505 IN (@list_of_analysis_ids)}?{
-- 505	Number of death records, by death_type_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 505 as analysis_id, 
	death_type_concept_id as stratum_1,
	COUNT_BIG(PERSON_ID) as count_value
from
	death d1
group by death_type_concept_id
;
--}



--{506 IN (@list_of_analysis_ids)}?{
-- 506	Distribution of age by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 506 as analysis_id,
	gender_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select p1.gender_concept_id,
	d1.death_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by p1.gender_concept_id order by d1.death_year - p1.year_of_birth))/(COUNT_BIG(d1.death_year - p1.year_of_birth) over (partition by p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, min(year(death_date)) as death_year
from death
group by person_id
) d1
on p1.person_id = d1.person_id
) t1
group by gender_concept_id
;
--}



--{509 IN (@list_of_analysis_ids)}?{
-- 509	Number of death records with invalid person_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 509 as analysis_id, 
	COUNT_BIG(d1.PERSON_ID) as count_value
from
	death d1
		left join person p1
		on d1.person_id = p1.person_id
where p1.person_id is null
;
--}



--{510 IN (@list_of_analysis_ids)}?{
-- 510	Number of death records outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 510 as analysis_id, 
	COUNT_BIG(d1.PERSON_ID) as count_value
from
	death d1
		left join observation_period op1
		on d1.person_id = op1.person_id
		and d1.death_date >= op1.observation_period_start_date
		and d1.death_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{511 IN (@list_of_analysis_ids)}?{
-- 511	Distribution of time from death to last condition
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 511 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(datediff(dd,d1.death_date, t0.max_date)) over ()+1) as p1
from death d1
	inner join
	(
		select person_id, max(condition_start_date) as max_date
		from condition_occurrence
		group by person_id
	) t0
	on d1.person_id = t0.person_id
) t1
;
--}


--{512 IN (@list_of_analysis_ids)}?{
-- 512	Distribution of time from death to last drug
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 512 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(datediff(dd,d1.death_date, t0.max_date)) over ()+1) as p1
from death d1
	inner join
	(
		select person_id, max(drug_exposure_start_date) as max_date
		from drug_exposure
		group by person_id
	) t0
	on d1.person_id = t0.person_id
) t1
;
--}


--{513 IN (@list_of_analysis_ids)}?{
-- 513	Distribution of time from death to last visit
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 513 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(datediff(dd,d1.death_date, t0.max_date)) over ()+1) as p1
from death d1
	inner join
	(
		select person_id, max(visit_start_date) as max_date
		from visit_occurrence
		group by person_id
	) t0
	on d1.person_id = t0.person_id
) t1
;
--}


--{514 IN (@list_of_analysis_ids)}?{
-- 514	Distribution of time from death to last procedure
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 514 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(datediff(dd,d1.death_date, t0.max_date)) over ()+1) as p1
from death d1
	inner join
	(
		select person_id, max(procedure_date) as max_date
		from procedure_occurrence
		group by person_id
	) t0
	on d1.person_id = t0.person_id
) t1
;
--}


--{515 IN (@list_of_analysis_ids)}?{
-- 515	Distribution of time from death to last observation
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 515 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select datediff(dd,d1.death_date, t0.max_date) as count_value,
	1.0*(row_number() over (order by datediff(dd,d1.death_date, t0.max_date)))/(COUNT_BIG(datediff(dd,d1.death_date, t0.max_date)) over ()+1) as p1
from death d1
	inner join
	(
		select person_id, max(observation_date) as max_date
		from observation
		group by person_id
	) t0
	on d1.person_id = t0.person_id
) t1
;
--}



/********************************************

ACHILLES Analyses on PROCEDURE_OCCURRENCE table

*********************************************/



--{600 IN (@list_of_analysis_ids)}?{
-- 600	Number of persons with at least one procedure occurrence, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 600 as analysis_id, 
	po1.procedure_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
group by po1.procedure_CONCEPT_ID
;
--}


--{601 IN (@list_of_analysis_ids)}?{
-- 601	Number of procedure occurrence records, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 601 as analysis_id, 
	po1.procedure_CONCEPT_ID as stratum_1,
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
group by po1.procedure_CONCEPT_ID
;
--}



--{602 IN (@list_of_analysis_ids)}?{
-- 602	Number of persons by procedure occurrence start month, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 602 as analysis_id,   
	po1.procedure_concept_id as stratum_1,
	YEAR(procedure_date)*100 + month(procedure_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
procedure_occurrence po1
group by po1.procedure_concept_id, 
	YEAR(procedure_date)*100 + month(procedure_date)
;
--}



--{603 IN (@list_of_analysis_ids)}?{
-- 603	Number of distinct procedure occurrence concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 603 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_procedures as count_value,
	1.0*(row_number() over (order by num_procedures))/(COUNT_BIG(num_procedures) over ()+1) as p1
from
	(
	select po1.person_id, COUNT_BIG(distinct po1.procedure_concept_id) as num_procedures
	from
	procedure_occurrence po1
	group by po1.person_id
	) t0
) t1
;
--}



--{604 IN (@list_of_analysis_ids)}?{
-- 604	Number of persons with at least one procedure occurrence, by procedure_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 604 as analysis_id,   
	po1.procedure_concept_id as stratum_1,
	YEAR(procedure_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(procedure_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
procedure_occurrence po1
on p1.person_id = po1.person_id
group by po1.procedure_concept_id, 
	YEAR(procedure_date),
	p1.gender_concept_id,
	floor((year(procedure_date) - p1.year_of_birth)/10)
;
--}

--{605 IN (@list_of_analysis_ids)}?{
-- 605	Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 605 as analysis_id, 
	po1.procedure_CONCEPT_ID as stratum_1,
	po1.procedure_type_concept_id as stratum_2,
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
group by po1.procedure_CONCEPT_ID,	
	po1.procedure_type_concept_id
;
--}



--{606 IN (@list_of_analysis_ids)}?{
-- 606	Distribution of age by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 606 as analysis_id,
	procedure_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select po1.procedure_concept_id,
	p1.gender_concept_id,
	po1.procedure_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by po1.procedure_concept_id, p1.gender_concept_id order by po1.procedure_start_year - p1.year_of_birth))/(COUNT_BIG(po1.procedure_start_year - p1.year_of_birth) over (partition by po1.procedure_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, procedure_concept_id, min(year(procedure_date)) as procedure_start_year
from procedure_occurrence
group by person_id, procedure_concept_id
) po1
on p1.person_id = po1.person_id
) t1
group by procedure_concept_id, gender_concept_id
;
--}







--{609 IN (@list_of_analysis_ids)}?{
-- 609	Number of procedure occurrence records with invalid person_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 609 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
	left join PERSON p1
	on p1.person_id = po1.person_id
where p1.person_id is null
;
--}


--{610 IN (@list_of_analysis_ids)}?{
-- 610	Number of procedure occurrence records outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 610 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
	left join observation_period op1
	on op1.person_id = po1.person_id
	and po1.procedure_date >= op1.observation_period_start_date
	and po1.procedure_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}



--{612 IN (@list_of_analysis_ids)}?{
-- 612	Number of procedure occurrence records with invalid provider_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 612 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
	left join provider p1
	on p1.provider_id = po1.associated_provider_id
where po1.associated_provider_id is not null
	and p1.provider_id is null
;
--}

--{613 IN (@list_of_analysis_ids)}?{
-- 613	Number of procedure occurrence records with invalid visit_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 613 as analysis_id,  
	COUNT_BIG(po1.PERSON_ID) as count_value
from
	procedure_occurrence po1
	left join visit_occurrence vo1
	on po1.visit_occurrence_id = vo1.visit_occurrence_id
where po1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}


--{620 IN (@list_of_analysis_ids)}?{
-- 620	Number of procedure occurrence records by condition occurrence start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 620 as analysis_id,   
	YEAR(procedure_date)*100 + month(procedure_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
procedure_occurrence po1
group by YEAR(procedure_date)*100 + month(procedure_date)
;
--}


/********************************************

ACHILLES Analyses on DRUG_EXPOSURE table

*********************************************/




--{700 IN (@list_of_analysis_ids)}?{
-- 700	Number of persons with at least one drug occurrence, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 700 as analysis_id, 
	de1.drug_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct de1.PERSON_ID) as count_value
from
	drug_exposure de1
group by de1.drug_CONCEPT_ID
;
--}


--{701 IN (@list_of_analysis_ids)}?{
-- 701	Number of drug occurrence records, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 701 as analysis_id, 
	de1.drug_CONCEPT_ID as stratum_1,
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
group by de1.drug_CONCEPT_ID
;
--}



--{702 IN (@list_of_analysis_ids)}?{
-- 702	Number of persons by drug occurrence start month, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 702 as analysis_id,   
	de1.drug_concept_id as stratum_1,
	YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
drug_exposure de1
group by de1.drug_concept_id, 
	YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date)
;
--}



--{703 IN (@list_of_analysis_ids)}?{
-- 703	Number of distinct drug exposure concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 703 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_drugs as count_value,
	1.0*(row_number() over (order by num_drugs))/(COUNT_BIG(num_drugs) over ()+1) as p1
from
	(
	select de1.person_id, COUNT_BIG(distinct de1.drug_concept_id) as num_drugs
	from
	drug_exposure de1
	group by de1.person_id
	) t0
) t1
;
--}



--{704 IN (@list_of_analysis_ids)}?{
-- 704	Number of persons with at least one drug occurrence, by drug_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 704 as analysis_id,   
	de1.drug_concept_id as stratum_1,
	YEAR(drug_exposure_start_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(drug_exposure_start_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
drug_exposure de1
on p1.person_id = de1.person_id
group by de1.drug_concept_id, 
	YEAR(drug_exposure_start_date),
	p1.gender_concept_id,
	floor((year(drug_exposure_start_date) - p1.year_of_birth)/10)
;
--}

--{705 IN (@list_of_analysis_ids)}?{
-- 705	Number of drug occurrence records, by drug_concept_id by drug_type_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 705 as analysis_id, 
	de1.drug_CONCEPT_ID as stratum_1,
	de1.drug_type_concept_id as stratum_2,
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
group by de1.drug_CONCEPT_ID,	
	de1.drug_type_concept_id
;
--}



--{706 IN (@list_of_analysis_ids)}?{
-- 706	Distribution of age by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 706 as analysis_id,
	drug_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select de1.drug_concept_id,
	p1.gender_concept_id,
	de1.drug_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by de1.drug_concept_id, p1.gender_concept_id order by de1.drug_start_year - p1.year_of_birth))/(COUNT_BIG(de1.drug_start_year - p1.year_of_birth) over (partition by de1.drug_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, drug_concept_id, min(year(drug_exposure_start_date)) as drug_start_year
from drug_exposure
group by person_id, drug_concept_id
) de1
on p1.person_id = de1.person_id
) t1
group by drug_concept_id, gender_concept_id
;
--}




--{709 IN (@list_of_analysis_ids)}?{
-- 709	Number of drug exposure records with invalid person_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 709 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
	left join PERSON p1
	on p1.person_id = de1.person_id
where p1.person_id is null
;
--}


--{710 IN (@list_of_analysis_ids)}?{
-- 710	Number of drug exposure records outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 710 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
	left join observation_period op1
	on op1.person_id = de1.person_id
	and de1.drug_exposure_start_date >= op1.observation_period_start_date
	and de1.drug_exposure_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{711 IN (@list_of_analysis_ids)}?{
-- 711	Number of drug exposure records with end date < start date
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 711 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
where de1.drug_exposure_end_date < de1.drug_exposure_start_date
;
--}


--{712 IN (@list_of_analysis_ids)}?{
-- 712	Number of drug exposure records with invalid provider_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 712 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
	left join provider p1
	on p1.provider_id = de1.prescribing_provider_id
where de1.prescribing_provider_id is not null
	and p1.provider_id is null
;
--}

--{713 IN (@list_of_analysis_ids)}?{
-- 713	Number of drug exposure records with invalid visit_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 713 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_exposure de1
	left join visit_occurrence vo1
	on de1.visit_occurrence_id = vo1.visit_occurrence_id
where de1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}



--{715 IN (@list_of_analysis_ids)}?{
-- 715	Distribution of days_supply by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 715 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	days_supply as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by days_supply))/(COUNT_BIG(days_supply) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1

) t1
group by drug_concept_id
;
--}



--{716 IN (@list_of_analysis_ids)}?{
-- 716	Distribution of refills by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 716 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	refills as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by refills))/(COUNT_BIG(refills) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
) t1
group by drug_concept_id
;
--}





--{717 IN (@list_of_analysis_ids)}?{
-- 717	Distribution of quantity by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 717 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	quantity as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by quantity))/(COUNT_BIG(quantity) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
) t1
group by drug_concept_id
;
--}


--{720 IN (@list_of_analysis_ids)}?{
-- 720	Number of drug exposure records by condition occurrence start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 720 as analysis_id,   
	YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
drug_exposure de1
group by YEAR(drug_exposure_start_date)*100 + month(drug_exposure_start_date)
;
--}

/********************************************

ACHILLES Analyses on OBSERVATION table

*********************************************/



--{800 IN (@list_of_analysis_ids)}?{
-- 800	Number of persons with at least one observation occurrence, by observation_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 800 as analysis_id, 
	o1.observation_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct o1.PERSON_ID) as count_value
from
	observation o1
group by o1.observation_CONCEPT_ID
;
--}


--{801 IN (@list_of_analysis_ids)}?{
-- 801	Number of observation occurrence records, by observation_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 801 as analysis_id, 
	o1.observation_CONCEPT_ID as stratum_1,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
group by o1.observation_CONCEPT_ID
;
--}



--{802 IN (@list_of_analysis_ids)}?{
-- 802	Number of persons by observation occurrence start month, by observation_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 802 as analysis_id,   
	o1.observation_concept_id as stratum_1,
	YEAR(observation_date)*100 + month(observation_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
observation o1
group by o1.observation_concept_id, 
	YEAR(observation_date)*100 + month(observation_date)
;
--}



--{803 IN (@list_of_analysis_ids)}?{
-- 803	Number of distinct observation occurrence concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 803 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_observations as count_value,
	1.0*(row_number() over (order by num_observations))/(COUNT_BIG(num_observations) over ()+1) as p1
from
	(
	select o1.person_id, COUNT_BIG(distinct o1.observation_concept_id) as num_observations
	from
	observation o1
	group by o1.person_id
	) t0
) t1
;
--}



--{804 IN (@list_of_analysis_ids)}?{
-- 804	Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 804 as analysis_id,   
	o1.observation_concept_id as stratum_1,
	YEAR(observation_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(observation_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
observation o1
on p1.person_id = o1.person_id
group by o1.observation_concept_id, 
	YEAR(observation_date),
	p1.gender_concept_id,
	floor((year(observation_date) - p1.year_of_birth)/10)
;
--}

--{805 IN (@list_of_analysis_ids)}?{
-- 805	Number of observation occurrence records, by observation_concept_id by observation_type_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 805 as analysis_id, 
	o1.observation_CONCEPT_ID as stratum_1,
	o1.observation_type_concept_id as stratum_2,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
group by o1.observation_CONCEPT_ID,	
	o1.observation_type_concept_id
;
--}



--{806 IN (@list_of_analysis_ids)}?{
-- 806	Distribution of age by observation_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 806 as analysis_id,
	observation_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select o1.observation_concept_id,
	p1.gender_concept_id,
	o1.observation_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by o1.observation_concept_id, p1.gender_concept_id order by o1.observation_start_year - p1.year_of_birth))/(COUNT_BIG(o1.observation_start_year - p1.year_of_birth) over (partition by o1.observation_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, observation_concept_id, min(year(observation_date)) as observation_start_year
from observation
group by person_id, observation_concept_id
) o1
on p1.person_id = o1.person_id
) t1
group by observation_concept_id, gender_concept_id
;
--}

--{807 IN (@list_of_analysis_ids)}?{
-- 807	Number of observation occurrence records, by observation_concept_id and unit_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 807 as analysis_id, 
	o1.observation_CONCEPT_ID as stratum_1,
	o1.unit_concept_id as stratum_2,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
group by o1.observation_CONCEPT_ID,
	o1.unit_concept_id
;
--}





--{809 IN (@list_of_analysis_ids)}?{
-- 809	Number of observation records with invalid person_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 809 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
	left join PERSON p1
	on p1.person_id = o1.person_id
where p1.person_id is null
;
--}


--{810 IN (@list_of_analysis_ids)}?{
-- 810	Number of observation records outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 810 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
	left join observation_period op1
	on op1.person_id = o1.person_id
	and o1.observation_date >= op1.observation_period_start_date
	and o1.observation_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}



--{812 IN (@list_of_analysis_ids)}?{
-- 812	Number of observation records with invalid provider_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 812 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
	left join provider p1
	on p1.provider_id = o1.associated_provider_id
where o1.associated_provider_id is not null
	and p1.provider_id is null
;
--}

--{813 IN (@list_of_analysis_ids)}?{
-- 813	Number of observation records with invalid visit_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 813 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
	left join visit_occurrence vo1
	on o1.visit_occurrence_id = vo1.visit_occurrence_id
where o1.visit_occurrence_id is not null
	and vo1.visit_occurrence_id is null
;
--}


--{814 IN (@list_of_analysis_ids)}?{
-- 814	Number of observation records with no value (numeric, string, or concept)
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 814 as analysis_id,  
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
where o1.value_as_number is null
	and o1.value_as_string is null
	and o1.value_as_concept_id is null
;
--}


--{815 IN (@list_of_analysis_ids)}?{
-- 815	Distribution of numeric values, by observation_concept_id and unit_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 815 as analysis_id,
	observation_concept_id as stratum_1,
	unit_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select observation_concept_id, unit_concept_id,
	value_as_number as count_value,
	1.0*(row_number() over (partition by observation_concept_id, unit_concept_id order by value_as_number))/(COUNT_BIG(value_as_number) over (partition by observation_concept_id, unit_concept_id)+1) as p1
from observation o1
where o1.unit_concept_id is not null
	and o1.value_as_number is not null
) t1
group by observation_concept_id, unit_concept_id
;
--}


--{816 IN (@list_of_analysis_ids)}?{
-- 816	Distribution of low range, by observation_concept_id and unit_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 816 as analysis_id,
	observation_concept_id as stratum_1,
	unit_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select observation_concept_id, unit_concept_id,
	range_low as count_value,
	1.0*(row_number() over (partition by observation_concept_id, unit_concept_id order by range_low))/(COUNT_BIG(range_low) over (partition by observation_concept_id, unit_concept_id)+1) as p1
from observation o1
where o1.unit_concept_id is not null
	and o1.value_as_number is not null
	and o1.range_low is not null
	and o1.range_high is not null
) t1
group by observation_concept_id, unit_concept_id
;
--}


--{817 IN (@list_of_analysis_ids)}?{
-- 817	Distribution of high range, by observation_concept_id and unit_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 817 as analysis_id,
	observation_concept_id as stratum_1,
	unit_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select observation_concept_id, unit_concept_id,
	range_high as count_value,
	1.0*(row_number() over (partition by observation_concept_id, unit_concept_id order by range_high))/(COUNT_BIG(range_high) over (partition by observation_concept_id, unit_concept_id)+1) as p1
from observation o1
where o1.unit_concept_id is not null
	and o1.value_as_number is not null
	and o1.range_low is not null
	and o1.range_high is not null
) t1
group by observation_concept_id, unit_concept_id
;
--}



--{818 IN (@list_of_analysis_ids)}?{
-- 818	Number of observation records below/within/above normal range, by observation_concept_id and unit_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, count_value)
select 818 as analysis_id,  
	observation_concept_id as stratum_1,
	unit_concept_id as stratum_2,
	case when o1.value_as_number < o1.range_low then 'Below Range Low'
		when o1.value_as_number >= o1.range_low and o1.value_as_number <= o1.range_high then 'Within Range'
		when o1.value_as_number > o1.range_high then 'Above Range High'
		else 'Other' end as stratum_3,
	COUNT_BIG(o1.PERSON_ID) as count_value
from
	observation o1
where o1.value_as_number is not null
	and o1.unit_concept_id is not null
	and o1.range_low is not null
	and o1.range_high is not null
group by observation_concept_id,
	unit_concept_id,
	  case when o1.value_as_number < o1.range_low then 'Below Range Low'
		when o1.value_as_number >= o1.range_low and o1.value_as_number <= o1.range_high then 'Within Range'
		when o1.value_as_number > o1.range_high then 'Above Range High'
		else 'Other' end
;
--}



--{820 IN (@list_of_analysis_ids)}?{
-- 820	Number of observation records by condition occurrence start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 820 as analysis_id,   
	YEAR(observation_date)*100 + month(observation_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
observation o1
group by YEAR(observation_date)*100 + month(observation_date)
;
--}




/********************************************

ACHILLES Analyses on DRUG_ERA table

*********************************************/


--{900 IN (@list_of_analysis_ids)}?{
-- 900	Number of persons with at least one drug occurrence, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 900 as analysis_id, 
	de1.drug_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct de1.PERSON_ID) as count_value
from
	drug_era de1
group by de1.drug_CONCEPT_ID
;
--}


--{901 IN (@list_of_analysis_ids)}?{
-- 901	Number of drug occurrence records, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 901 as analysis_id, 
	de1.drug_CONCEPT_ID as stratum_1,
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_era de1
group by de1.drug_CONCEPT_ID
;
--}



--{902 IN (@list_of_analysis_ids)}?{
-- 902	Number of persons by drug occurrence start month, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 902 as analysis_id,   
	de1.drug_concept_id as stratum_1,
	YEAR(drug_era_start_date)*100 + month(drug_era_start_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
drug_era de1
group by de1.drug_concept_id, 
	YEAR(drug_era_start_date)*100 + month(drug_era_start_date)
;
--}



--{903 IN (@list_of_analysis_ids)}?{
-- 903	Number of distinct drug era concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 903 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_drugs as count_value,
	1.0*(row_number() over (order by num_drugs))/(COUNT_BIG(num_drugs) over ()+1) as p1
from
	(
	select de1.person_id, COUNT_BIG(distinct de1.drug_concept_id) as num_drugs
	from
	drug_era de1
	group by de1.person_id
	) t0
) t1
;
--}



--{904 IN (@list_of_analysis_ids)}?{
-- 904	Number of persons with at least one drug occurrence, by drug_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 904 as analysis_id,   
	de1.drug_concept_id as stratum_1,
	YEAR(drug_era_start_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(drug_era_start_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
drug_era de1
on p1.person_id = de1.person_id
group by de1.drug_concept_id, 
	YEAR(drug_era_start_date),
	p1.gender_concept_id,
	floor((year(drug_era_start_date) - p1.year_of_birth)/10)
;
--}




--{906 IN (@list_of_analysis_ids)}?{
-- 906	Distribution of age by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 906 as analysis_id,
	drug_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select de1.drug_concept_id,
	p1.gender_concept_id,
	de1.drug_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by de1.drug_concept_id, p1.gender_concept_id order by de1.drug_start_year - p1.year_of_birth))/(COUNT_BIG(de1.drug_start_year - p1.year_of_birth) over (partition by de1.drug_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, drug_concept_id, min(year(drug_era_start_date)) as drug_start_year
from drug_era
group by person_id, drug_concept_id
) de1
on p1.person_id = de1.person_id
) t1
group by drug_concept_id, gender_concept_id
;
--}





--{907 IN (@list_of_analysis_ids)}?{
-- 907	Distribution of drug era length, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 907 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	datediff(dd,drug_era_start_date, drug_era_end_date) as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by datediff(dd,drug_era_start_date, drug_era_end_date)))/(COUNT_BIG(datediff(dd,drug_era_start_date, drug_era_end_date)) over (partition by drug_concept_id)+1) as p1
from  drug_era de1

) t1
group by drug_concept_id
;
--}



--{908 IN (@list_of_analysis_ids)}?{
-- 908	Number of drug eras with invalid person
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 908 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_era de1
	left join PERSON p1
	on p1.person_id = de1.person_id
where p1.person_id is null
;
--}


--{909 IN (@list_of_analysis_ids)}?{
-- 909	Number of drug eras outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 909 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_era de1
	left join observation_period op1
	on op1.person_id = de1.person_id
	and de1.drug_era_start_date >= op1.observation_period_start_date
	and de1.drug_era_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{910 IN (@list_of_analysis_ids)}?{
-- 910	Number of drug eras with end date < start date
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 910 as analysis_id,  
	COUNT_BIG(de1.PERSON_ID) as count_value
from
	drug_era de1
where de1.drug_era_end_date < de1.drug_era_start_date
;
--}



--{920 IN (@list_of_analysis_ids)}?{
-- 920	Number of drug era records by drug era start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 920 as analysis_id,   
	YEAR(drug_era_start_date)*100 + month(drug_era_start_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
drug_era de1
group by YEAR(drug_era_start_date)*100 + month(drug_era_start_date)
;
--}





/********************************************

ACHILLES Analyses on CONDITION_ERA table

*********************************************/


--{1000 IN (@list_of_analysis_ids)}?{
-- 1000	Number of persons with at least one condition occurrence, by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1000 as analysis_id, 
	ce1.condition_CONCEPT_ID as stratum_1,
	COUNT_BIG(distinct ce1.PERSON_ID) as count_value
from
	condition_era ce1
group by ce1.condition_CONCEPT_ID
;
--}


--{1001 IN (@list_of_analysis_ids)}?{
-- 1001	Number of condition occurrence records, by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1001 as analysis_id, 
	ce1.condition_CONCEPT_ID as stratum_1,
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	condition_era ce1
group by ce1.condition_CONCEPT_ID
;
--}



--{1002 IN (@list_of_analysis_ids)}?{
-- 1002	Number of persons by condition occurrence start month, by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, count_value)
select 1002 as analysis_id,   
	ce1.condition_concept_id as stratum_1,
	YEAR(condition_era_start_date)*100 + month(condition_era_start_date) as stratum_2, 
	COUNT_BIG(distinct PERSON_ID) as count_value
from
condition_era ce1
group by ce1.condition_concept_id, 
	YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
;
--}



--{1003 IN (@list_of_analysis_ids)}?{
-- 1003	Number of distinct condition era concepts per person
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1003 as analysis_id,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select num_conditions as count_value,
	1.0*(row_number() over (order by num_conditions))/(COUNT_BIG(num_conditions) over ()+1) as p1
from
	(
	select ce1.person_id, COUNT_BIG(distinct ce1.condition_concept_id) as num_conditions
	from
	condition_era ce1
	group by ce1.person_id
	) t0
) t1
;
--}



--{1004 IN (@list_of_analysis_ids)}?{
-- 1004	Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, stratum_2, stratum_3, stratum_4, count_value)
select 1004 as analysis_id,   
	ce1.condition_concept_id as stratum_1,
	YEAR(condition_era_start_date) as stratum_2,
	p1.gender_concept_id as stratum_3,
	floor((year(condition_era_start_date) - p1.year_of_birth)/10) as stratum_4, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from person p1
inner join
condition_era ce1
on p1.person_id = ce1.person_id
group by ce1.condition_concept_id, 
	YEAR(condition_era_start_date),
	p1.gender_concept_id,
	floor((year(condition_era_start_date) - p1.year_of_birth)/10)
;
--}




--{1006 IN (@list_of_analysis_ids)}?{
-- 1006	Distribution of age by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, stratum_2, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1006 as analysis_id,
	condition_concept_id as stratum_1,
	gender_concept_id as stratum_2,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select ce1.condition_concept_id,
	p1.gender_concept_id,
	ce1.condition_start_year - p1.year_of_birth as count_value,
	1.0*(row_number() over (partition by ce1.condition_concept_id, p1.gender_concept_id order by ce1.condition_start_year - p1.year_of_birth))/(COUNT_BIG(ce1.condition_start_year - p1.year_of_birth) over (partition by ce1.condition_concept_id, p1.gender_concept_id)+1) as p1
from person p1
inner join
(select person_id, condition_concept_id, min(year(condition_era_start_date)) as condition_start_year
from condition_era
group by person_id, condition_concept_id
) ce1
on p1.person_id = ce1.person_id
) t1
group by condition_concept_id, gender_concept_id
;
--}





--{1007 IN (@list_of_analysis_ids)}?{
-- 1007	Distribution of condition era length, by condition_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1007 as analysis_id,
	condition_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select condition_concept_id,
	datediff(dd,condition_era_start_date, condition_era_end_date) as count_value,
	1.0*(row_number() over (partition by condition_concept_id order by datediff(dd,condition_era_start_date, condition_era_end_date)))/(COUNT_BIG(datediff(dd,condition_era_start_date, condition_era_end_date)) over (partition by condition_concept_id)+1) as p1
from  condition_era ce1

) t1
group by condition_concept_id
;
--}



--{1008 IN (@list_of_analysis_ids)}?{
-- 1008	Number of condition eras with invalid person
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1008 as analysis_id,  
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	condition_era ce1
	left join PERSON p1
	on p1.person_id = ce1.person_id
where p1.person_id is null
;
--}


--{1009 IN (@list_of_analysis_ids)}?{
-- 1009	Number of condition eras outside valid observation period
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1009 as analysis_id,  
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	condition_era ce1
	left join observation_period op1
	on op1.person_id = ce1.person_id
	and ce1.condition_era_start_date >= op1.observation_period_start_date
	and ce1.condition_era_start_date <= op1.observation_period_end_date
where op1.person_id is null
;
--}


--{1010 IN (@list_of_analysis_ids)}?{
-- 1010	Number of condition eras with end date < start date
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1010 as analysis_id,  
	COUNT_BIG(ce1.PERSON_ID) as count_value
from
	condition_era ce1
where ce1.condition_era_end_date < ce1.condition_era_start_date
;
--}


--{1020 IN (@list_of_analysis_ids)}?{
-- 1020	Number of drug era records by drug era start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1020 as analysis_id,   
	YEAR(condition_era_start_date)*100 + month(condition_era_start_date) as stratum_1, 
	COUNT_BIG(PERSON_ID) as count_value
from
condition_era ce1
group by YEAR(condition_era_start_date)*100 + month(condition_era_start_date)
;
--}




/********************************************

ACHILLES Analyses on LOCATION table

*********************************************/

--{1100 IN (@list_of_analysis_ids)}?{
-- 1100	Number of persons by location 3-digit zip
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1100 as analysis_id,  
	left(l1.zip,3) as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON p1
	inner join LOCATION l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.zip is not null
group by left(l1.zip,3);
--}


--{1101 IN (@list_of_analysis_ids)}?{
-- 1101	Number of persons by location state
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1101 as analysis_id,  
	l1.state as stratum_1, COUNT_BIG(distinct person_id) as count_value
from PERSON p1
	inner join LOCATION l1
	on p1.location_id = l1.location_id
where p1.location_id is not null
	and l1.state is not null
group by l1.state;
--}


--{1102 IN (@list_of_analysis_ids)}?{
-- 1102	Number of care sites by location 3-digit zip
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1102 as analysis_id,  
	left(l1.zip,3) as stratum_1, COUNT_BIG(distinct care_site_id) as count_value
from care_site cs1
	inner join LOCATION l1
	on cs1.location_id = l1.location_id
where cs1.location_id is not null
	and l1.zip is not null
group by left(l1.zip,3);
--}


--{1103 IN (@list_of_analysis_ids)}?{
-- 1103	Number of care sites by location state
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1103 as analysis_id,  
	l1.state as stratum_1, COUNT_BIG(distinct care_site_id) as count_value
from care_site cs1
	inner join LOCATION l1
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
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1200 as analysis_id,  
	cs1.place_of_service_concept_id as stratum_1, COUNT_BIG(person_id) as count_value
from PERSON p1
	inner join care_site cs1
	on p1.care_site_id = cs1.care_site_id
where p1.care_site_id is not null
	and cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;
--}


--{1201 IN (@list_of_analysis_ids)}?{
-- 1201	Number of visits by place of service
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1201 as analysis_id,  
	cs1.place_of_service_concept_id as stratum_1, COUNT_BIG(visit_occurrence_id) as count_value
from visit_occurrence vo1
	inner join care_site cs1
	on vo1.care_site_id = cs1.care_site_id
where vo1.care_site_id is not null
	and cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;
--}


--{1202 IN (@list_of_analysis_ids)}?{
-- 1202	Number of care sites by place of service
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1202 as analysis_id,  
	cs1.place_of_service_concept_id as stratum_1, 
	COUNT_BIG(care_site_id) as count_value
from care_site cs1
where cs1.place_of_service_concept_id is not null
group by cs1.place_of_service_concept_id;
--}


/********************************************

ACHILLES Analyses on ORGANIZATION table

*********************************************/

--{1300 IN (@list_of_analysis_ids)}?{
-- 1300	Number of organizations by place of service
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1300 as analysis_id,  
	place_of_service_concept_id as stratum_1, 
	COUNT_BIG(organization_id) as count_value
from organization o1
where place_of_service_concept_id is not null
group by place_of_service_concept_id;
--}





/********************************************

ACHILLES Analyses on PAYOR_PLAN_PERIOD table

*********************************************/


--{1406 IN (@list_of_analysis_ids)}?{
-- 1406	Length of payer plan (days) of first payer plan period by gender
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1406 as analysis_id,
	gender_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select p1.gender_concept_id,
	DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date) as count_value,
	1.0*(row_number() over (partition by p1.gender_concept_id order by DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)))/(COUNT_BIG(DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)) over (partition by p1.gender_concept_id)+1) as p1
from PERSON p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
) t1
group by gender_concept_id
;
--}



--{1407 IN (@list_of_analysis_ids)}?{
-- 1407	Length of payer plan (days) of first payer plan period by age decile
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1407 as analysis_id,
	age_decile as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select floor((year(ppp1.payer_plan_period_START_DATE) - p1.YEAR_OF_BIRTH)/140) as age_decile,
	DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date) as count_value,
	1.0*(row_number() over (partition by floor((year(ppp1.payer_plan_period_START_DATE) - p1.YEAR_OF_BIRTH)/140) order by DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)))/(COUNT_BIG(DATEDIFF(dd,ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)) over (partition by floor((year(ppp1.payer_plan_period_START_DATE) - p1.YEAR_OF_BIRTH)/140))+1) as p1
from PERSON p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
) t1
group by age_decile
;
--}






--{1408 IN (@list_of_analysis_ids)}?{
-- 1408	Number of persons by length of payer plan period, in 30d increments
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1408 as analysis_id,  
	floor(DATEDIFF(dd, ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)/30) as stratum_1, 
	COUNT_BIG(distinct p1.person_id) as count_value
from PERSON p1
	inner join 
	(select person_id, 
		payer_plan_period_START_DATE, 
		payer_plan_period_END_DATE, 
		ROW_NUMBER() over (PARTITION by person_id order by payer_plan_period_start_date asc) as rn1
		 from payer_plan_period
	) ppp1
	on p1.PERSON_ID = ppp1.PERSON_ID
	where ppp1.rn1 = 1
group by floor(DATEDIFF(dd, ppp1.payer_plan_period_start_date, ppp1.payer_plan_period_end_date)/30)
;
--}


--{1409 IN (@list_of_analysis_ids)}?{
-- 1409	Number of persons with continuous payer plan in each year
-- Note: using temp table instead of nested query because this gives vastly improved

USE @results_schema; --Set to result schema so temp tables are created where user has write rights (Oracle)

IF OBJECT_ID('temp_dates', 'U') IS NOT NULL --This should only do something in Oracle
  drop table temp_dates;

select distinct 
  YEAR(payer_plan_period_start_date) as obs_year 
INTO
  #temp_dates
from 
  @CDM_schema.dbo.payer_plan_period
;

insert into ACHILLES_results (analysis_id, stratum_1, count_value)
select 1409 as analysis_id,  
	t1.obs_year as stratum_1, COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@CDM_schema.dbo.PERSON p1
	inner join 
  @CDM_schema.dbo.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates t1 
where year(ppp1.payer_plan_period_START_DATE) <= t1.obs_year
	and year(ppp1.payer_plan_period_END_DATE) >= t1.obs_year
group by t1.obs_year
;

truncate table #temp_dates;
drop table #temp_dates;

USE @CDM_schema;
--}


--{1410 IN (@list_of_analysis_ids)}?{
-- 1410	Number of persons with continuous payer plan in each month
-- Note: using temp table instead of nested query because this gives vastly improved performance in Oracle

USE @results_schema; --Set to result schema so temp tables are created where user has write rights (Oracle)

IF OBJECT_ID('temp_dates', 'U') IS NOT NULL --This should only do something in Oracle
  drop table temp_dates;

SELECT DISTINCT 
  YEAR(payer_plan_period_start_date)*100 + MONTH(payer_plan_period_start_date) AS obs_month,
  CAST(CAST(YEAR(payer_plan_period_start_date) AS VARCHAR(4)) +  RIGHT('0' + CAST(MONTH(payer_plan_period_start_date) AS VARCHAR(2)), 2) + '01' AS DATE) AS obs_month_start,  
  DATEADD(dd,-1,DATEADD(mm,1,CAST(CAST(YEAR(payer_plan_period_start_date) AS VARCHAR(4)) +  RIGHT('0' + CAST(MONTH(payer_plan_period_start_date) AS VARCHAR(2)), 2) + '01' AS DATE))) AS obs_month_end
INTO
  #temp_dates
FROM 
  @CDM_schema.dbo.payer_plan_period
;

insert into ACHILLES_results (analysis_id, stratum_1, count_value)
select 
  1410 as analysis_id, 
	obs_month as stratum_1, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	@CDM_schema.dbo.PERSON p1
	inner join 
  @CDM_schema.dbo.payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
	,
	#temp_dates
where ppp1.payer_plan_period_START_DATE <= obs_month_start
	and ppp1.payer_plan_period_END_DATE >= obs_month_end
group by obs_month
;

TRUNCATE TABLE #temp_dates;
DROP TABLE #temp_dates;

USE @CDM_schema;
--}



--{1411 IN (@list_of_analysis_ids)}?{
-- 1411	Number of persons by payer plan period start month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1411 as analysis_id, 
	cast(cast(YEAR(payer_plan_period_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(payer_plan_period_START_DATE) AS VARCHAR(2)), 2) + '01' as date) as stratum_1,
	 COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	PERSON p1
	inner join payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
group by cast(cast(YEAR(payer_plan_period_start_date) as varchar(4)) +  RIGHT('0' + CAST(month(payer_plan_period_START_DATE) AS VARCHAR(2)), 2) + '01' as date)
;
--}



--{1412 IN (@list_of_analysis_ids)}?{
-- 1412	Number of persons by payer plan period end month
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1412 as analysis_id,  
	cast(cast(YEAR(payer_plan_period_end_date) as varchar(4)) +  RIGHT('0' + CAST(month(payer_plan_period_end_DATE) AS VARCHAR(2)), 2) + '01' as date) as stratum_1, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	PERSON p1
	inner join payer_plan_period ppp1
	on p1.person_id = ppp1.person_id
group by cast(cast(YEAR(payer_plan_period_end_date) as varchar(4)) +  RIGHT('0' + CAST(month(payer_plan_period_end_DATE) AS VARCHAR(2)), 2) + '01' as date)
;
--}


--{1413 IN (@list_of_analysis_ids)}?{
-- 1413	Number of persons by number of payer plan periods
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1413 as analysis_id,  
	ppp1.num_periods as stratum_1, 
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	PERSON p1
	inner join (select person_id, COUNT_BIG(payer_plan_period_start_date) as num_periods from payer_plan_period group by PERSON_ID) ppp1
	on p1.person_id = ppp1.person_id
group by ppp1.num_periods
;
--}

--{1414 IN (@list_of_analysis_ids)}?{
-- 1414	Number of persons with payer plan period before year-of-birth
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1414 as analysis_id,  
	COUNT_BIG(distinct p1.PERSON_ID) as count_value
from
	PERSON p1
	inner join (select person_id, MIN(year(payer_plan_period_start_date)) as first_obs_year from payer_plan_period group by PERSON_ID) ppp1
	on p1.person_id = ppp1.person_id
where p1.year_of_birth > ppp1.first_obs_year
;
--}

--{1415 IN (@list_of_analysis_ids)}?{
-- 1415	Number of persons with payer plan period end < start
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1415 as analysis_id,  
	COUNT_BIG(ppp1.PERSON_ID) as count_value
from
	payer_plan_period ppp1
where ppp1.payer_plan_period_end_date < ppp1.payer_plan_period_start_date
;
--}






/********************************************

ACHILLES Analyses on DRUG_COST table

*********************************************/

--{1500 IN (@list_of_analysis_ids)}?{
-- 1500	Number of drug cost records with invalid drug exposure id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1500 as analysis_id,  
	COUNT_BIG(dc1.drug_cost_ID) as count_value
from
	drug_cost dc1
		left join drug_exposure de1
		on dc1.drug_exposure_id = de1.drug_exposure_id
where de1.drug_exposure_id is null
;
--}

--{1501 IN (@list_of_analysis_ids)}?{
-- 1501	Number of drug cost records with invalid payer plan period id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1501 as analysis_id,  
	COUNT_BIG(dc1.drug_cost_ID) as count_value
from
	drug_cost dc1
		left join payer_plan_period ppp1
		on dc1.payer_plan_period_id = ppp1.payer_plan_period_id
where dc1.payer_plan_period_id is not null
	and ppp1.payer_plan_period_id is null
;
--}


--{1502 IN (@list_of_analysis_ids)}?{
-- 1502	Distribution of paid copay, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1502 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	paid_copay as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by paid_copay))/(COUNT_BIG(paid_copay) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where paid_copay is not null
) t1
group by drug_concept_id
;
--}


--{1503 IN (@list_of_analysis_ids)}?{
-- 1503	Distribution of paid coinsurance, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1503 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	paid_coinsurance as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by paid_coinsurance))/(COUNT_BIG(paid_coinsurance) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where paid_coinsurance is not null
) t1
group by drug_concept_id
;
--}

--{1504 IN (@list_of_analysis_ids)}?{
-- 1504	Distribution of paid toward deductible, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1504 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	paid_toward_deductible as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by paid_toward_deductible))/(COUNT_BIG(paid_toward_deductible) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where paid_toward_deductible is not null
) t1
group by drug_concept_id
;
--}

--{1505 IN (@list_of_analysis_ids)}?{
-- 1505	Distribution of paid by payer, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1505 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	paid_by_payer as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by paid_by_payer))/(COUNT_BIG(paid_by_payer) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where paid_by_payer is not null
) t1
group by drug_concept_id
;
--}

--{1506 IN (@list_of_analysis_ids)}?{
-- 1506	Distribution of paid by coordination of benefit, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1506 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	paid_by_coordination_benefits as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by paid_by_coordination_benefits))/(COUNT_BIG(paid_by_coordination_benefits) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where paid_by_coordination_benefits is not null
) t1
group by drug_concept_id
;
--}

--{1507 IN (@list_of_analysis_ids)}?{
-- 1507	Distribution of total out-of-pocket, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1507 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	total_out_of_pocket as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by total_out_of_pocket))/(COUNT_BIG(total_out_of_pocket) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where total_out_of_pocket is not null
) t1
group by drug_concept_id
;
--}


--{1508 IN (@list_of_analysis_ids)}?{
-- 1508	Distribution of total paid, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1508 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	total_paid as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by total_paid))/(COUNT_BIG(total_paid) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where total_paid is not null
) t1
group by drug_concept_id
;
--}


--{1509 IN (@list_of_analysis_ids)}?{
-- 1509	Distribution of ingredient_cost, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1509 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	ingredient_cost as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by ingredient_cost))/(COUNT_BIG(ingredient_cost) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where ingredient_cost is not null
) t1
group by drug_concept_id
;
--}

--{1510 IN (@list_of_analysis_ids)}?{
-- 1510	Distribution of dispensing fee, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1510 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	dispensing_fee as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by dispensing_fee))/(COUNT_BIG(dispensing_fee) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where dispensing_fee is not null
) t1
group by drug_concept_id
;
--}

--{1511 IN (@list_of_analysis_ids)}?{
-- 1511	Distribution of average wholesale price, by drug_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1511 as analysis_id,
	drug_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select drug_concept_id,
	average_wholesale_price as count_value,
	1.0*(row_number() over (partition by drug_concept_id order by average_wholesale_price))/(COUNT_BIG(average_wholesale_price) over (partition by drug_concept_id)+1) as p1
from drug_exposure de1
	inner join
	drug_cost dc1
	on de1.drug_exposure_id = dc1.drug_exposure_id
where average_wholesale_price is not null
) t1
group by drug_concept_id
;
--}

/********************************************

ACHILLES Analyses on PROCEDURE_COST table

*********************************************/


--{1600 IN (@list_of_analysis_ids)}?{
-- 1600	Number of procedure cost records with invalid procedure exposure id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1600 as analysis_id,  
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	procedure_cost pc1
		left join procedure_occurrence po1
		on pc1.procedure_occurrence_id = po1.procedure_occurrence_id
where po1.procedure_occurrence_id is null
;
--}

--{1601 IN (@list_of_analysis_ids)}?{
-- 1601	Number of procedure cost records with invalid payer plan period id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1601 as analysis_id,  
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	procedure_cost pc1
		left join payer_plan_period ppp1
		on pc1.payer_plan_period_id = ppp1.payer_plan_period_id
where pc1.payer_plan_period_id is not null
	and ppp1.payer_plan_period_id is null
;
--}


--{1602 IN (@list_of_analysis_ids)}?{
-- 1602	Distribution of paid copay, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1602 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	paid_copay as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by paid_copay))/(COUNT_BIG(paid_copay) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where paid_copay is not null
) t1
group by procedure_concept_id
;
--}


--{1603 IN (@list_of_analysis_ids)}?{
-- 1603	Distribution of paid coinsurance, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1603 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	paid_coinsurance as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by paid_coinsurance))/(COUNT_BIG(paid_coinsurance) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where paid_coinsurance is not null
) t1
group by procedure_concept_id
;
--}

--{1604 IN (@list_of_analysis_ids)}?{
-- 1604	Distribution of paid toward deductible, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1604 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	paid_toward_deductible as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by paid_toward_deductible))/(COUNT_BIG(paid_toward_deductible) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where paid_toward_deductible is not null
) t1
group by procedure_concept_id
;
--}

--{1605 IN (@list_of_analysis_ids)}?{
-- 1605	Distribution of paid by payer, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1605 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	paid_by_payer as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by paid_by_payer))/(COUNT_BIG(paid_by_payer) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where paid_by_payer is not null
) t1
group by procedure_concept_id
;
--}

--{1606 IN (@list_of_analysis_ids)}?{
-- 1606	Distribution of paid by coordination of benefit, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1606 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	paid_by_coordination_benefits as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by paid_by_coordination_benefits))/(COUNT_BIG(paid_by_coordination_benefits) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where paid_by_coordination_benefits is not null
) t1
group by procedure_concept_id
;
--}

--{1607 IN (@list_of_analysis_ids)}?{
-- 1607	Distribution of total out-of-pocket, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1607 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	total_out_of_pocket as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by total_out_of_pocket))/(COUNT_BIG(total_out_of_pocket) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where total_out_of_pocket is not null
) t1
group by procedure_concept_id
;
--}


--{1608 IN (@list_of_analysis_ids)}?{
-- 1608	Distribution of total paid, by procedure_concept_id
insert into @results_schema.dbo.ACHILLES_results_dist (analysis_id, stratum_1, count_value, min_value, max_value, avg_value, stdev_value, median_value, p10_value, p25_value, p75_value, p90_value)
select 1608 as analysis_id,
	procedure_concept_id as stratum_1,
	COUNT_BIG(count_value) as count_value,
	min(count_value) as min_value,
	max(count_value) as max_value,
	avg(1.0*count_value) as avg_value,
	stdev(count_value) as stdev_value,
	max(case when p1<=0.50 then count_value else -9999 end) as median_value,
	max(case when p1<=0.10 then count_value else -9999 end) as p10_value,
	max(case when p1<=0.25 then count_value else -9999 end) as p25_value,
	max(case when p1<=0.75 then count_value else -9999 end) as p75_value,
	max(case when p1<=0.90 then count_value else -9999 end) as p90_value
from
(
select procedure_concept_id,
	total_paid as count_value,
	1.0*(row_number() over (partition by procedure_concept_id order by total_paid))/(COUNT_BIG(total_paid) over (partition by procedure_concept_id)+1) as p1
from procedure_occurrence po1
	inner join
	procedure_cost pc1
	on po1.procedure_occurrence_id = pc1.procedure_occurrence_id
where total_paid is not null
) t1
group by procedure_concept_id
;
--}


--{1609 IN (@list_of_analysis_ids)}?{
-- 1609	Number of records by disease_class_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1609 as analysis_id, 
	disease_class_concept_id as stratum_1, 
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	procedure_cost pc1
where disease_class_concept_id is not null
group by disease_class_concept_id
;
--}


--{1610 IN (@list_of_analysis_ids)}?{
-- 1610	Number of records by revenue_code_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1610 as analysis_id, 
	revenue_code_concept_id as stratum_1, 
	COUNT_BIG(pc1.procedure_cost_ID) as count_value
from
	procedure_cost pc1
where revenue_code_concept_id is not null
group by revenue_code_concept_id
;
--}



/********************************************

ACHILLES Analyses on COHORT table

*********************************************/

--{1700 IN (@list_of_analysis_ids)}?{
-- 1700	Number of records by cohort_concept_id
insert into @results_schema.dbo.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1700 as analysis_id, 
	cohort_concept_id as stratum_1, 
	COUNT_BIG(subject_ID) as count_value
from
	cohort c1
group by cohort_concept_id
;
--}


--{1701 IN (@list_of_analysis_ids)}?{
-- 1701	Number of records with cohort end date < cohort start date
insert into @results_schema.dbo.ACHILLES_results (analysis_id, count_value)
select 1701 as analysis_id, 
	COUNT_BIG(subject_ID) as count_value
from
	cohort c1
where c1.cohort_end_date < c1.cohort_start_date
;
--}


delete from @results_schema.dbo.ACHILLES_results where count_value <= @smallcellcount;
delete from @results_schema.dbo.ACHILLES_results_dist where count_value <= @smallcellcount;


--Achilles_Heel part:
USE @results_schema;

IF OBJECT_ID('ACHILLES_HEEL_results', 'U') IS NOT NULL
  DROP TABLE ACHILLES_HEEL_results;

CREATE TABLE ACHILLES_HEEL_results (
  analysis_id INT,
	ACHILLES_HEEL_warning VARCHAR(255)
	);

--check for non-zero counts from checks of improper data (invalid ids, out-of-bound data, inconsistent dates)
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; count (n=' + cast(or1.count_value as VARCHAR) + ') should not be > 0' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (
		7,
		8,
		9,
		114,
		115,
		207,
		208,
		209,
		210,
		302,
		409,
		410,
		411,
		412,
		413,
		509,
		510,
		609,
		610,
		612,
		613,
		709,
		710,
		711,
		712,
		713,
		809,
		810,
		812,
		813,
		814,
		908,
		909,
		910,
		1008,
		1009,
		1010,
		1415,
		1500,
		1501,
		1600,
		1601,
		1701
		) --all explicit counts of data anamolies
	AND or1.count_value > 0;

--distributions where min should not be negative
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT ord1.analysis_id,
  'ERROR: ' + cast(ord1.analysis_id as VARCHAR) + ' - ' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.min_value) as VARCHAR) + '); value should not be negative' AS ACHILLES_HEEL_warning
FROM ACHILLES_results_dist ord1
INNER JOIN ACHILLES_analysis oa1
	ON ord1.analysis_id = oa1.analysis_id
WHERE ord1.analysis_id IN (
		103,
		105,
		206,
		406,
		506,
		606,
		706,
		715,
		716,
		717,
		806,
		906,
		907,
		1006,
		1007,
		1502,
		1503,
		1504,
		1505,
		1506,
		1507,
		1508,
		1509,
		1510,
		1511,
		1602,
		1603,
		1604,
		1605,
		1606,
		1607,
		1608
		)
	AND ord1.min_value < 0
	GROUP BY ord1.analysis_id,  oa1.analysis_name;

--death distributions where max should not be positive
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT ord1.analysis_id,
  'WARNING: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.max_value) as VARCHAR) + '); value should not be positive, otherwise its a zombie with data >1mo after death ' AS ACHILLES_HEEL_warning
FROM ACHILLES_results_dist ord1
INNER JOIN ACHILLES_analysis oa1
	ON ord1.analysis_id = oa1.analysis_id
WHERE ord1.analysis_id IN (
		511,
		512,
		513,
		514,
		515
		)
	AND ord1.max_value > 30
GROUP BY ord1.analysis_id, oa1.analysis_name;

--invalid concept_id
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
LEFT JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (
		2,
		4,
		5,
		200,
		301,
		400,
		500,
		505,
		600,
		700,
		800,
		900,
		1000,
		1609,
		1610
		)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id IS NULL
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--invalid type concept_id
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_2) AS VARCHAR) + ' concepts in data are not in vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
LEFT JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_2 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (
		405,
		605,
		705,
		805
		)
	AND or1.stratum_2 IS NOT NULL
	AND c1.concept_id IS NULL
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--invalid concept_id
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'WARNING: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; data with unmapped concepts' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (
		2,
		4,
		5,
		200,
		301,
		400,
		500,
		505,
		600,
		700,
		800,
		900,
		1000,
		1609,
		1610
		)
	AND or1.stratum_1 = '0'
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--concept from the wrong vocabulary
--gender  - 12 HL7
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (HL7 Sex)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (2)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		12
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--race  - 13 CDC Race
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (CDC Race)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (4)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		13
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--ethnicity - 44 ethnicity
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (CMS Ethnicity)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (5)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		44
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--place of service - 14 CMS place of service, 24 OMOP visit
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (CMS place of service or OMOP visit)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (202)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		14,
		24
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--specialty - 48 specialty
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (Specialty)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (301)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		48
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--condition occurrence, era - 1 SNOMED
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (SNOMED)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (
		400,
		1000
		)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		1
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--drug exposure - 8 RxNorm
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (RxNorm)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (
		700,
		900
		)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		8
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--procedure - 4 CPT4/5 HCPCS/3 ICD9P
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (CPT4/HCPCS/ICD9P)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (600)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		3,
		4,
		5
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--observation  - 6 LOINC
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (LOINC)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (800)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		6
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;


--disease class - 40 DRG
INSERT INTO ACHILLES_HEEL_results (
  analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (DRG)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (1609)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		40
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--revenue code - 43 revenue code
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary (revenue code)' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @CDM_schema.dbo.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (1610)
	AND or1.stratum_1 IS NOT NULL
	AND c1.vocabulary_id NOT IN (
		0,
		43
		)
GROUP BY or1.analysis_id,
	oa1.analysis_name;


--ERROR:  year of birth in the future
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have year of birth in the future, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (3)
	AND CAST(or1.stratum_1 AS INT) > year(getdate())
	AND or1.count_value > 0
GROUP BY or1.analysis_id,
  oa1.analysis_name;


--WARNING:  year of birth < 1900
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have year of birth < 1900, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (3)
	AND cAST(or1.stratum_1 AS INT) < 1900
	AND or1.count_value > 0
GROUP BY or1.analysis_id,
  oa1.analysis_name;

--ERROR:  age < 0
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have age < 0, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (101)
	AND CAST(or1.stratum_1 AS INT) < 0
	AND or1.count_value > 0
GROUP BY or1.analysis_id,
  oa1.analysis_name;

--ERROR: age > 100
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have age > 100, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (101)
	AND CAST(or1.stratum_1 AS INT) > 100
	AND or1.count_value > 0
GROUP BY or1.analysis_id,
  oa1.analysis_name;

--WARNING:  monthly change > 100%
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT ar1.analysis_id,
	'WARNING: ' + cast(ar1.analysis_id as VARCHAR) + '-' + aa1.analysis_name + '; theres a 100% change in monthly count of events' AS ACHILLES_HEEL_warning
FROM ACHILLES_analysis aa1
INNER JOIN ACHILLES_results ar1
	ON aa1.analysis_id = ar1.analysis_id
INNER JOIN ACHILLES_results ar2
	ON ar1.analysis_id = ar2.analysis_id
		AND ar1.analysis_id IN (
			420,
			620,
			720,
			820,
			920,
			1020
			)
WHERE (
		CAST(ar1.stratum_1 AS INT) + 1 = CAST(ar2.stratum_1 AS INT)
		OR CAST(ar1.stratum_1 AS INT) + 89 = CAST(ar2.stratum_1 AS INT)
		)
	AND 1.0 * abs(ar2.count_value - ar1.count_value) / ar1.count_value > 1
	AND ar1.count_value > 10;

--WARNING:  monthly change > 100% at concept level
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT ar1.analysis_id,
	'WARNING: ' + cast(ar1.analysis_id as VARCHAR) + '-' + aa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT ar1.stratum_1) AS VARCHAR) + ' concepts have a 100% change in monthly count of events' AS ACHILLES_HEEL_warning
FROM ACHILLES_analysis aa1
INNER JOIN ACHILLES_results ar1
	ON aa1.analysis_id = ar1.analysis_id
INNER JOIN ACHILLES_results ar2
	ON ar1.analysis_id = ar2.analysis_id
		AND ar1.stratum_1 = ar2.stratum_1
		AND ar1.analysis_id IN (
			402,
			602,
			702,
			802,
			902,
			1002
			)
WHERE (
		CAST(ar1.stratum_2 AS INT) + 1 = CAST(ar2.stratum_2 AS INT)
		OR CAST(ar1.stratum_2 AS INT) + 89 = CAST(ar2.stratum_2 AS INT)
		)
	AND 1.0 * abs(ar2.count_value - ar1.count_value) / ar1.count_value > 1
	AND ar1.count_value > 10
GROUP BY ar1.analysis_id,
	aa1.analysis_name;

--WARNING: days_supply > 180 
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT ord1.analysis_id,
  'ERROR: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.max_value) as VARCHAR) + '); value should not be > 180' AS ACHILLES_HEEL_warning
FROM ACHILLES_results_dist ord1
INNER JOIN ACHILLES_analysis oa1
	ON ord1.analysis_id = oa1.analysis_id
WHERE ord1.analysis_id IN (715)
	AND ord1.max_value > 180
GROUP BY ord1.analysis_id, oa1.analysis_name;

--WARNING:  refills > 10
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT ord1.analysis_id,
  'ERROR: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.max_value) as VARCHAR) + '); value should not be > 10' AS ACHILLES_HEEL_warning
FROM ACHILLES_results_dist ord1
INNER JOIN ACHILLES_analysis oa1
	ON ord1.analysis_id = oa1.analysis_id
WHERE ord1.analysis_id IN (716)
	AND ord1.max_value > 10
GROUP BY ord1.analysis_id, oa1.analysis_name;

--WARNING: quantity > 600
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT DISTINCT ord1.analysis_id,
  'ERROR: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(count(ord1.max_value) as VARCHAR) + '); value should not be > 600' AS ACHILLES_HEEL_warning
FROM ACHILLES_results_dist ord1
INNER JOIN ACHILLES_analysis oa1
	ON ord1.analysis_id = oa1.analysis_id
WHERE ord1.analysis_id IN (717)
	AND ord1.max_value > 600
GROUP BY ord1.analysis_id, oa1.analysis_name;


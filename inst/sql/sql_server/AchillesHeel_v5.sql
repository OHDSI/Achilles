/******************************************************************

# @file ACHILLESHEEL.SQL
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

Achilles Heel - data quality assessment based on database profiling summary statistics

SQL for ACHILLES results (for either OMOP CDM v4 or OMOP CDM v5)


*******************************************************************/

{DEFAULT @cdm_database_schema = 'CDM.dbo'}
{DEFAULT @results_database = 'scratch'}
{DEFAULT @source_name = 'CDM NAME'}
{DEFAULT @smallcellcount = 5}
{DEFAULT @createTable = TRUE}

 
--Achilles_Heel part:
USE @results_database;

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
		118,
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
  'ERROR: ' + cast(ord1.analysis_id as VARCHAR) + ' - ' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.min_value) as VARCHAR) + '); min value should not be negative' AS ACHILLES_HEEL_warning
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
  'WARNING: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.max_value) as VARCHAR) + '); max value should not be positive, otherwise its a zombie with data >1mo after death ' AS ACHILLES_HEEL_warning
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
LEFT JOIN @cdm_database_schema.concept c1
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
LEFT JOIN @cdm_database_schema.concept c1
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
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (2)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('gender')
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--race  - 13 CDC Race
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (4)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('race')
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
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (5)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('ethnicity')
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--place of service - 14 CMS place of service, 24 OMOP visit
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (202)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('visit')
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
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (301)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('provider specialty')
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--condition occurrence, era - 1 SNOMED
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (
		400,
		1000
		)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('condition','condition/drug', 'condition/meas', 'condition/obs', 'condition/procedure')
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--drug exposure - 8 RxNorm
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (
		700,
		900
		)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('drug','condition/drug', 'device/drug', 'drug/measurement', 'drug/obs', 'drug/procedure')
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--procedure - 4 CPT4/5 HCPCS/3 ICD9P
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; ' + cast(COUNT_BIG(DISTINCT stratum_1) AS VARCHAR) + ' concepts in data are not in correct vocabulary' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (600)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('procedure','condition/procedure', 'device/procedure', 'drug/procedure', 'obs/procedure')
GROUP BY or1.analysis_id,
	oa1.analysis_name;

--observation  - 6 LOINC

--NOT APPLICABLE IN CDMv5


--disease class - 40 DRG

--NOT APPLICABLE IN CDMV5

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
INNER JOIN @cdm_database_schema.concept c1
	ON or1.stratum_1 = CAST(c1.concept_id AS VARCHAR)
WHERE or1.analysis_id IN (1610)
	AND or1.stratum_1 IS NOT NULL
	AND c1.concept_id <> 0 
  AND lower(c1.domain_id) NOT IN ('revenue code')
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


--WARNING:  year of birth < 1800
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have year of birth < 1800, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (3)
	AND cAST(or1.stratum_1 AS INT) < 1800
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

--ERROR: age > 150
INSERT INTO ACHILLES_HEEL_results (
	analysis_id,
	ACHILLES_HEEL_warning
	)
SELECT or1.analysis_id,
	'ERROR: ' + cast(or1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + '; should not have age > 150, (n=' + cast(sum(or1.count_value) as VARCHAR) + ')' AS ACHILLES_HEEL_warning
FROM ACHILLES_results or1
INNER JOIN ACHILLES_analysis oa1
	ON or1.analysis_id = oa1.analysis_id
WHERE or1.analysis_id IN (101)
	AND CAST(or1.stratum_1 AS INT) > 150
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
  'WARNING: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.max_value) as VARCHAR) + '); max value should not be > 180' AS ACHILLES_HEEL_warning
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
  'WARNING: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(COUNT_BIG(ord1.max_value) as VARCHAR) + '); max value should not be > 10' AS ACHILLES_HEEL_warning
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
  'WARNING: ' + cast(ord1.analysis_id as VARCHAR) + '-' + oa1.analysis_name + ' (count = ' + cast(count(ord1.max_value) as VARCHAR) + '); max value should not be > 600' AS ACHILLES_HEEL_warning
FROM ACHILLES_results_dist ord1
INNER JOIN ACHILLES_analysis oa1
	ON ord1.analysis_id = oa1.analysis_id
WHERE ord1.analysis_id IN (717)
	AND ord1.max_value > 600
GROUP BY ord1.analysis_id, oa1.analysis_name;


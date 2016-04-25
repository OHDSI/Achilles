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

Achilles Report 

SQL for OMOP CDM v5


*******************************************************************/

{DEFAULT @cdm_database = 'CDM'}
{DEFAULT @results_database = 'scratch'}
{DEFAULT @results_database_schema = 'scratch.dbo'}
{DEFAULT @source_name = 'CDM NAME'}
{DEFAULT @createTable = TRUE}

  

--{@createTable}?{


IF OBJECT_ID('@results_database_schema.ACHILLES_report', 'U') IS NOT NULL
  drop table @results_database_schema.ACHILLES_report;

create table @results_database_schema.ACHILLES_report
(
	analysis_id int,
	stratum_1 varchar(255),
	stratum_2 varchar(255),
	stratum_3 varchar(255),
	stratum_4 varchar(255),
	stratum_5 varchar(255),
	count_value bigint
);



--} : {else if not createTable
delete from @results_database_schema.ACHILLES_report;
--}

/****
7. do reports


****/

use @cdm_database;

select * from (
select 'measurement' as table_name,measurement_source_value as source_value, count(*) as cnt from measurement where measurement_concept_id = 0 group by measurement_source_value 
union
select 'procedure_occurrence' as table_name,procedure_source_value as source_value, count(*) as cnt from procedure_occurrence where procedure_concept_id = 0 group by procedure_source_value 
union
select 'drug_exposure' as table_name,drug_source_value as source_value, count(*) as cnt from drug_exposure where drug_concept_id = 0 group by drug_source_value 
union
select 'condition_occurrence' as table_name,condition_source_value as source_value, count(*) as cnt from condition_occurrence where condition_concept_id = 0 group by condition_source_value 
) a
where cnt >= 1000 --use other threshold if needed (e.g., 10)
order by a.table_name desc, cnt desc
;



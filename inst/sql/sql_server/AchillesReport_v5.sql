/******************************************************************

# @file ACHILLESReport_v5.SQL
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


--populate lkup table for analysis_id  (ideally the CSV would be the single source for this :-(  )
--1900. reports

--insert into @results_database_schema.ACHILLES_analysis (analysis_id, analysis_name)
--	values (1, 'Number of persons');

--} : {else if not createTable
delete from @results_database_schema.ACHILLES_results where analysis_id IN (1900);
--delete from @results_database_schema.ACHILLES_results_dist where analysis_id IN (@list_of_analysis_ids);
}


--start of actual code


use @cdm_database_schema;



INSERT INTO @results_database_schema.ACHILLES_results (analysis_id, stratum_1, count_value)
select 1900 as analysis_id, table_name as stratum_1, source_value as stratum_2, cnt as count_value
 from (
select 'measurement' as table_name,measurement_source_value as source_value, COUNT_BIG(*) as cnt from measurement where measurement_concept_id = 0 group by measurement_source_value 
union
select 'procedure_occurrence' as table_name,procedure_source_value as source_value, COUNT_BIG(*) as cnt from procedure_occurrence where procedure_concept_id = 0 group by procedure_source_value 
union
select 'drug_exposure' as table_name,drug_source_value as source_value, COUNT_BIG(*) as cnt from drug_exposure where drug_concept_id = 0 group by drug_source_value 
union
select 'condition_occurrence' as table_name,condition_source_value as source_value, COUNT_BIG(*) as cnt from condition_occurrence where condition_concept_id = 0 group by condition_source_value 
) a
where cnt >= 1 --use other threshold if needed (e.g., 10)
order by a.table_name desc, cnt desc
;

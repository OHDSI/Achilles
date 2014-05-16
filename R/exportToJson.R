# @file exportToJson
#
# Copyright 2014 Observational Health Data Sciences and Informatics
#
# This file is part of Achilles
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
# @author Chris Knoll
# @author Frank DeFalco

#' @title exportToJson
#'
#' @description
#' \code{exportToJson} Exports Achilles statistics into a JSON form for reports.
#'
#' @details
#' Creates individual files for each report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema			string name of databsae schema that contains OMOP CDM and vocabulary
#' @param outputPath		a folder location to save the JSON files
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   exportToJson(connectionDetails, "cdm4_sim", "C:/achilles.web/data/cdm_name/)
#' }
#' @export
exportToJson <- function (connectionDetails, cdmSchema, outputPath)
{
  generatePersonReport(connectionDetails, cdmSchema, outputPath)
}

generatePersonReport <- function(connectionDetails, cdmSchema, outputPath)
{
  output = {}
  conn <- connect(connectionDetails)
  
  # 1.  Title:  Population
  # a.  Visualization: Table
  # b.	Row #1:  CDM source name
  # c.	Row #2:  # of persons
  pathToSql <- system.file("sql/sql_server", "1_Population.sql", package="Achilles")
  parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)
  renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema)$sql
  personSummaryData <- fetch(dbSendQuery(conn,renderedSql), n=-1)
  
  output$Summary = personSummaryData
  
  # 2.  Title:  Gender distribution
  # a.   Visualization: Pie
  # b.	Category:  Gender
  # c.	Value:  % of persons  
  pathToSql <- system.file("sql/sql_server", "2_Gender.sql", package="Achilles")
  parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)
  renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema)$sql
  genderData <- fetch(dbSendQuery(conn,renderedSql), n=-1)
  
  output$GenderData = genderData
  
  # 3.  Title: Race distribution
  # a.  Visualization: Pie
  # b.	Category: Race
  # c.	Value: % of persons
  pathToSql <- system.file("sql/sql_server", "3_Race.sql", package="Achilles")
  parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)
  renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema)$sql
  raceData <- fetch(dbSendQuery(conn,renderedSql), n=-1)
  
  output$RaceData = raceData
  
  # 4.  Title: Ethnicity distribution
  # a.  Visualization: Pie
  # b.	Category: Ethnicity
  # c.	Value: % of persons
  pathToSql <- system.file("sql/sql_server", "4_Ethnicity.sql", package="Achilles")
  parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)
  renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema)$sql
  ethnicityData <- fetch(dbSendQuery(conn,renderedSql), n=-1)
  
  output$EthnicityData = ethnicityData
  
  # 5.  Title:  Year of birth distribution
  # a.  Visualization:  Histogram
  # b.	Category: Year of birth
  # c.	Value:  # of persons
  birthYearHist <- {}
  
  pathToSql <- system.file("sql/sql_server", "5_YearOfBirth_Stats.sql", package="Achilles")
  parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)
  renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema)$sql
  birthYearStats <- fetch(dbSendQuery(conn,renderedSql), n=-1)
  birthYearHist$min = birthYearStats$MinValue
  birthYearHist$max = birthYearStats$MaxValue
  birthYearHist$intervalSize = birthYearStats$IntervalSize
  birthYearHist$intervals = (birthYearStats$MaxValue - birthYearStats$MinValue) / birthYearStats$IntervalSize
  
  pathToSql <- system.file("sql/sql_server", "5_YearOfBirth_Data.sql", package="Achilles")
  parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)
  renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema)$sql
  birthYearData <- fetch(dbSendQuery(conn,renderedSql), n=-1)
  birthYearHist$data <- birthYearData

  output$BirthYearHistogram <- birthYearHist
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "person.json", sep=""))
}

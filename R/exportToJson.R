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
  # create output path if it doesn't already exist, warns if it does
  dir.create(outputPath)
  
  generatePersonReport(connectionDetails, cdmSchema, outputPath)
  generateObservationPeriodReport(connectionDetails, cdmSchema, outputPath)
  generateConditionReports(connectionDetails, cdmSchema, outputPath)
  generateConditionTreemap(connectionDetails, cdmSchema, outputPath)
}

generateConditionTreemap <- function(connectionDetails, cdmSchema, outputPath) {
  conn <- connect(connectionDetails)
  
  queryConditionTreemap <- renderAndTranslate(sqlFilename = "export/condition/sqlConditionTreemap.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       CDM_schema = cdmSchema
  )  
  
  dataConditionTreemap <- dbGetQuery(conn,queryConditionTreemap)  
  
  write(toJSON(dataConditionTreemap,method="C"),paste(outputPath, "condition_treemap.json", sep=''))
}

generateConditionReports <- function(connectionDetails, cdmSchema, outputPath) {
  conn <- connect(connectionDetails)
  
  queryPrevalenceByGenderAgeYear <- renderAndTranslate(sqlFilename = "export/condition/sqlPrevalenceByGenderAgeYear.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  
  queryPrevalenceByMonth <- renderAndTranslate(sqlFilename = "export/condition/sqlPrevalenceByMonth.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       CDM_schema = cdmSchema
  )

  queryConditionsByType <- renderAndTranslate(sqlFilename = "export/condition/sqlConditionsByType.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       CDM_schema = cdmSchema
  )

  queryAgeAtFirstDiagnosis <- renderAndTranslate(sqlFilename = "export/condition/sqlAgeAtFirstDiagnosis.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       CDM_schema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- dbGetQuery(conn,queryPrevalenceByGenderAgeYear)  
  dataPrevalenceByMonth <- dbGetQuery(conn,queryPrevalenceByMonth)  
  dataConditionsByType <- dbGetQuery(conn,queryConditionsByType)  
  dataAgeAtFirstDiagnosis <- dbGetQuery(conn,queryAgeAtFirstDiagnosis)    
  
  uniqueConcepts <- unique(dataPrevalenceByGenderAgeYear$ConceptId)
  dir.create(file.path(outputPath,"conditions"))
  
  buildConditionReport <- function(concept_id) {
    report <- {}
    report$PrevalenceByGenderAgeYear <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$ConceptId == concept_id,c(3,4,5,6)]    
    report$PrevalenceByMonth <- dataPrevalenceByMonth[dataPrevalenceByMonth$ConceptId == concept_id,c(3,4)]
    report$ConditionsByType <- dataConditionsByType[dataConditionsByType$ConceptId == concept_id,c(2,3)]
    report$AgeAtFirstDiagnosis <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$ConceptId == concept_id,c(2,3,4,5,6,7,8,9)]
    filename <- paste(outputPath, "conditions/condition_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
  }
  
  lapply(uniqueConcepts, buildConditionReport)  
}

generatePersonReport <- function(connectionDetails, cdmSchema, outputPath)
{
  output = {}
  conn <- connect(connectionDetails)
  
  # 1.  Title:  Population
  # a.  Visualization: Table
  # b.	Row #1:  CDM source name
  # c.	Row #2:  # of persons
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/population.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  
  personSummaryData <- dbGetQuery(conn,renderedSql)
  
  output$Summary = personSummaryData
  
  # 2.  Title:  Gender distribution
  # a.   Visualization: Pie
  # b.	Category:  Gender
  # c.	Value:  % of persons  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/gender.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  genderData <- dbGetQuery(conn,renderedSql)
  
  output$GenderData = genderData
  
  # 3.  Title: Race distribution
  # a.  Visualization: Pie
  # b.	Category: Race
  # c.	Value: % of persons
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/race.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  raceData <- dbGetQuery(conn,renderedSql)
  
  output$RaceData = raceData
  
  # 4.  Title: Ethnicity distribution
  # a.  Visualization: Pie
  # b.	Category: Ethnicity
  # c.	Value: % of persons
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/ethnicity.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  ethnicityData <- dbGetQuery(conn,renderedSql)
  
  output$EthnicityData = ethnicityData
  
  # 5.  Title:  Year of birth distribution
  # a.  Visualization:  Histogram
  # b.	Category: Year of birth
  # c.	Value:  # of persons
  birthYearHist <- {}
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/yearofbirth_stats.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  birthYearStats <- dbGetQuery(conn,renderedSql)
  birthYearHist$min = birthYearStats$MinValue
  birthYearHist$max = birthYearStats$MaxValue
  birthYearHist$intervalSize = birthYearStats$IntervalSize
  birthYearHist$intervals = (birthYearStats$MaxValue - birthYearStats$MinValue) / birthYearStats$IntervalSize
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/yearofbirth_data.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  birthYearData <- dbGetQuery(conn,renderedSql)
  birthYearHist$data <- birthYearData

  output$BirthYearHistogram <- birthYearHist
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "person.json", sep=""))
}

generateObservationPeriodReport <- function(connectionDetails, cdmSchema, outputPath)
{
  output = {}
  conn <- connect(connectionDetails)
  
  # 1.  Title:  Age at time of first observation
  # a.  Visualization:  Histogram
  # b.  Category: Age
  # c.	Value:  # of persons
  
  ageAtFirstObservationHist <- {}
  
  # stats are hard coded for this result to make x-axis consistent across datasources
  ageAtFirstObservationHist$min = 0
  ageAtFirstObservationHist$max =100
  ageAtFirstObservationHist$intervalSize = 1
  ageAtFirstObservationHist$intervals = 100
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/ageatfirst.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  ageAtFirstObservationData <- dbGetQuery(conn,renderedSql)
  ageAtFirstObservationHist$data = ageAtFirstObservationData
  output$AgeAtFirstObservationHistogram <- ageAtFirstObservationHist
  
  # 2.  Title: Age by gender
  # a.	Visualization:  Side-by-side boxplot
  # b.	Category:  Gender
  # c.	Values:  Min/25%/Median/95%/Max  - age at time of first observation
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/agebygender.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  ageByGenderData <- dbGetQuery(conn,renderedSql)
  output$AgeByGender = ageByGenderData
  
  # 3.  Title: Length of observation
  # a.	Visualization:  bar
  # b.	Category:  length of observation period, 30d increments
  # c.	Values: # of persons
  
  observationLengthHist <- {}
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlength_stats.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  
  observationLengthStats <- dbGetQuery(conn,renderedSql)
  observationLengthHist$min = observationLengthStats$MinValue
  observationLengthHist$max = observationLengthStats$MaxValue
  observationLengthHist$intervalSize = observationLengthStats$IntervalSize
  observationLengthHist$intervals = (observationLengthStats$MaxValue - observationLengthStats$MinValue) / observationLengthStats$IntervalSize
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlength_data.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  observationLengthData <- dbGetQuery(conn,renderedSql)
  observationLengthHist$data <- observationLengthData
  
  output$ObservationLengthHistogram = observationLengthHist
  
  
  # 4.  Title:  Cumulative duration of observation
  # a.	Visualization:  scatterplot
  # b.	X-axis:  length of observation period
  # c.	Y-axis:  % of population observed
  # d.	Note:  will look like a Kaplan-Meier âsurvivalâ plot, but information is the same as shown in âlength of observationâ barchart, just plotted as cumulative 
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/cumulativeduration.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )  
  
  cumulativeDurationData <- dbGetQuery(conn,renderedSql)
  output$CumulativeDuration = cumulativeDurationData
  
  # 5.  Title:  Observation period length distribution, by gender
  # a.	Visualization:  side-by-side boxplot
  # b.	Category: Gender
  # c.	Values: Min/25%/Median/95%/Max  length of observation period
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlengthbygender.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  opLengthByGenderData <- dbGetQuery(conn,renderedSql)
  output$ObservationPeriodLengthByGender = opLengthByGenderData
  
  # 6.  Title:  Observation period length distribution, by age
  # a.	Visualization:  side-by-side boxplot
  # b.	Category: Age decile
  # c.	Values: Min/25%/Median/95%/Max  length of observation period
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlengthbyage.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  opLengthByAgeData <- dbGetQuery(conn,renderedSql)
  output$ObservationPeriodLengthByAge = opLengthByAgeData
  
  # 7.  Title:  Number of persons with continuous observation by year
  # a.	Visualization:  Histogram
  # b.	Category:  Year
  # c.	Values:  # of persons with continuous coverage
  
  observedByYearHist <- {}
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observedbyyear_stats.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  observedByYearStats <- dbGetQuery(conn,renderedSql)
  observedByYearHist$min = observedByYearStats$MinValue
  observedByYearHist$max = observedByYearStats$MaxValue
  observedByYearHist$intervalSize = observedByYearStats$IntervalSize
  observedByYearHist$intervals = (observedByYearStats$MaxValue - observedByYearStats$MinValue) / observedByYearStats$IntervalSize
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observedbyyear_data.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  
  observedByYearData <- dbGetQuery(conn,renderedSql)
  observedByYearHist$data <- observedByYearData
  
  output$ObservedByYearHistogram = observedByYearHist
  
  # 8.  Title:  Number of persons with continuous observation by month
  # a.	Visualization:  Histogram
  # b.	Category:  Month/year
  # c.	Values:  # of persons with continuous coverage
  
  observedByMonth <- {}
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observedbymonth.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  observedByMonth <- dbGetQuery(conn,renderedSql)
    
  output$ObservedByMonth = observedByMonth
  
  # 9.  Title:  Number of observation periods per person
  # a.	Visualization:  Pie
  # b.	Category:  Number of observation periods
  # c.	Values:  # of persons 
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/periodsperperson.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema
  )
  personPeriodsData <- dbGetQuery(conn,renderedSql)
  output$PersonPeriodsData = personPeriodsData
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "observationperiod.json", sep=""))
}

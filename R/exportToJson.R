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
#' @param cdmSchema  		Name of the database schema that contains the vocabulary files
#' @param resultsSchema			Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   exportToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="C:/achilles.web/data/cdm_name/)
#' }
#' @export
exportToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd())
{
  if (missing(resultsSchema))
    resultsSchema <- cdmSchema
  
  # create output path if it doesn't already exist, warn if it does
  if (file.exists(outputPath)){
    writeLines(paste("Warning: folder",outputPath,"already exists"))
  } else {
    dir.create(paste(outputPath,"/",sep=""))
  }
  
  # connect to the results schema
  connectionDetails$schema = resultsSchema
  conn <- connect(connectionDetails)
  
  # generate reports
  generatePersonReport(conn, connectionDetails$dbms, cdmSchema, outputPath)
  generateObservationPeriodReport(conn, connectionDetails$dbms, cdmSchema, outputPath)
  generateConditionTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath)  
  generateConditionReports(conn, connectionDetails$dbms, cdmSchema, outputPath)
  generateDrugTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath)  
  generateDrugReports(conn, connectionDetails$dbms, cdmSchema, outputPath)
  generateProcedureTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath)
  generateProcedureReports(conn, connectionDetails$dbms, cdmSchema, outputPath)
  generateDashboardReport(outputPath)
  
  dummy <- dbDisconnect(conn)
  
  writeLines(paste("Export complete. JSON files can now be found in",outputPath))
}

generateDrugTreemap <- function(conn, dbms,cdmSchema, outputPath) {
  writeLines("Generating drug treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryDrugTreemap <- renderAndTranslate(sqlFilename = "export/drug/sqlDrugTreemap.sql",
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )  
  
  dataDrugTreemap <- querySql(conn,dbms,queryDrugTreemap) 
  
  write(toJSON(dataDrugTreemap,method="C"),paste(outputPath, "/drug_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)  
}

generateConditionTreemap <- function(conn, dbms, cdmSchema, outputPath) {
  writeLines("Generating condition treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryConditionTreemap <- renderAndTranslate(sqlFilename = "export/condition/sqlConditionTreemap.sql",
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )  
  
  dataConditionTreemap <- querySql(conn,dbms,queryConditionTreemap) 
  
  write(toJSON(dataConditionTreemap,method="C"),paste(outputPath, "/condition_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)
}

generateConditionReports <- function(conn, dbms, cdmSchema, outputPath) {
  writeLines("Generating condition reports")
  
  conditionsFolder <- file.path(outputPath,"conditions")
  if (file.exists(conditionsFolder)){
    writeLines(paste("Warning: folder ",conditionsFolder," already exists"))
  } else {
    dir.create(paste(conditionsFolder,"/",sep=""))

  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- renderAndTranslate(sqlFilename = "export/condition/sqlPrevalenceByGenderAgeYear.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- renderAndTranslate(sqlFilename = "export/condition/sqlPrevalenceByMonth.sql",
                                               packageName = "Achilles",
                                               dbms = dbms,
                                               cdmSchema = cdmSchema
  )
  
  queryConditionsByType <- renderAndTranslate(sqlFilename = "export/condition/sqlConditionsByType.sql",
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstDiagnosis <- renderAndTranslate(sqlFilename = "export/condition/sqlAgeAtFirstDiagnosis.sql",
                                                 packageName = "Achilles",
                                                 dbms = dbms,
                                                 cdmSchema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,dbms,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,dbms,queryPrevalenceByMonth)  
  dataConditionsByType <- querySql(conn,dbms,queryConditionsByType)    
  dataAgeAtFirstDiagnosis <- querySql(conn,dbms,queryAgeAtFirstDiagnosis)    
  
  uniqueConcepts <- unique(dataPrevalenceByGenderAgeYear$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  buildConditionReport <- function(concept_id) {
    report <- {}
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$CONDITIONS_BY_TYPE <- dataConditionsByType[dataConditionsByType$CONDITION_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_DIAGNOSIS <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    filename <- paste(outputPath, "/conditions/condition_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildConditionReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateDrugReports <- function(conn, dbms, cdmSchema, outputPath) {
  writeLines("Generating drug reports")
  
  drugsFolder <- file.path(outputPath,"drugs")
  if (file.exists(drugsFolder)){
    writeLines(paste("Warning: folder ",drugsFolder," already exists"))
  } else {
    dir.create(paste(drugsFolder,"/",sep=""))
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryAgeAtFirstExposure <- renderAndTranslate(sqlFilename = "export/drug/sqlAgeAtFirstExposure.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryDaysSupplyDistribution <- renderAndTranslate(sqlFilename = "export/drug/sqlDaysSupplyDistribution.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryDrugsByType <- renderAndTranslate(sqlFilename = "export/drug/sqlDrugsByType.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryPrevalenceByGenderAgeYear <- renderAndTranslate(sqlFilename = "export/drug/sqlPrevalenceByGenderAgeYear.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- renderAndTranslate(sqlFilename = "export/drug/sqlPrevalenceByMonth.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryQuantityDistribution <- renderAndTranslate(sqlFilename = "export/drug/sqlQuantityDistribution.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryRefillsDistribution <- renderAndTranslate(sqlFilename = "export/drug/sqlRefillsDistribution.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )

  dataAgeAtFirstExposure <- querySql(conn,dbms,queryAgeAtFirstExposure) 
  dataDaysSupplyDistribution <- querySql(conn,dbms,queryDaysSupplyDistribution) 
  dataDrugsByType <- querySql(conn,dbms,queryDrugsByType) 
  dataPrevalenceByGenderAgeYear <- querySql(conn,dbms,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,dbms,queryPrevalenceByMonth)
  dataQuantityDistribution <- querySql(conn,dbms,queryQuantityDistribution) 
  dataRefillsDistribution <- querySql(conn,dbms,queryRefillsDistribution) 
  
  uniqueConcepts <- unique(dataPrevalenceByGenderAgeYear$CONCEPT_ID)
    
  totalCount <- length(uniqueConcepts)
  
  buildDrugReport <- function(concept_id) {
    report <- {}
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$DRUG_CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$DAYS_SUPPLY_DISTRIBUTION <- dataDaysSupplyDistribution[dataDaysSupplyDistribution$DRUG_CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    report$DRUGS_BY_TYPE <- dataDrugsByType[dataDrugsByType$DRUG_CONCEPT_ID == concept_id, c(3,4)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]  
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$QUANTITY_DISTRIBUTION <- dataQuantityDistribution[dataQuantityDistribution$DRUG_CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    report$REFILLS_DISTRIBUTION <- dataRefillsDistribution[dataRefillsDistribution$DRUG_CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    
    filename <- paste(outputPath, "/drugs/drug_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildDrugReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateProcedureTreemap <- function(conn, dbms, cdmSchema, outputPath) {
  writeLines("Generating procedure treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryProcedureTreemap <- renderAndTranslate(sqlFilename = "export/procedure/sqlProcedureTreemap.sql",
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )  
  
  dataProcedureTreemap <- querySql(conn,dbms,queryProcedureTreemap) 
  
  write(toJSON(dataProcedureTreemap,method="C"),paste(outputPath, "/procedure_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)
}

generateProcedureReports <- function(conn, dbms, cdmSchema, outputPath) {
  writeLines("Generating procedure reports")
  
  proceduresFolder <- file.path(outputPath,"procedures")
  if (file.exists(proceduresFolder)){
    writeLines(paste("Warning: folder ",proceduresFolder," already exists"))
  } else {
    dir.create(paste(proceduresFolder,"/",sep=""))
    
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- renderAndTranslate(sqlFilename = "export/procedure/sqlPrevalenceByGenderAgeYear.sql",
                                                       packageName = "Achilles",
                                                       dbms = dbms,
                                                       cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- renderAndTranslate(sqlFilename = "export/procedure/sqlPrevalenceByMonth.sql",
                                               packageName = "Achilles",
                                               dbms = dbms,
                                               cdmSchema = cdmSchema
  )
  
  queryProceduresByType <- renderAndTranslate(sqlFilename = "export/procedure/sqlProceduresByType.sql",
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstOccurrence <- renderAndTranslate(sqlFilename = "export/procedure/sqlAgeAtFirstOccurrence.sql",
                                                 packageName = "Achilles",
                                                 dbms = dbms,
                                                 cdmSchema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,dbms,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,dbms,queryPrevalenceByMonth)  
  dataProceduresByType <- querySql(conn,dbms,queryProceduresByType)    
  dataAgeAtFirstOccurrence <- querySql(conn,dbms,queryAgeAtFirstOccurrence)    
  
  uniqueConcepts <- unique(dataPrevalenceByGenderAgeYear$CONCEPT_ID)
  
  #todo: remove this for debugging
  uniqueConcepts <- head(uniqueConcepts,n=10)
  
  totalCount <- length(uniqueConcepts)
  
  buildProcedureReport <- function(concept_id) {
    report <- {}
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$PROCEDURES_BY_TYPE <- dataProceduresByType[dataProceduresByType$PROCEDURE_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    filename <- paste(outputPath, "/procedures/procedure_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildProcedureReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)
}


generatePersonReport <- function(conn, dbms, cdmSchema, outputPath)
{
  writeLines("Generating person reports")
  progressBar <- txtProgressBar(max=7,style=3)
  progress = 0
  output = {}
  
  
  # 1.  Title:  Population
  # a.  Visualization: Table
  # b.	Row #1:  CDM source name
  # c.	Row #2:  # of persons
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/population.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  
  personSummaryData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$SUMMARY = personSummaryData
  
  # 2.  Title:  Gender distribution
  # a.   Visualization: Pie
  # b.	Category:  Gender
  # c.	Value:  % of persons  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/gender.sql",
                                    packageName = "Achilles",
                                    dbms = dbms,
                                    cdmSchema = cdmSchema
  )
  genderData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$GENDER_DATA = genderData
  
  # 3.  Title: Race distribution
  # a.  Visualization: Pie
  # b.	Category: Race
  # c.	Value: % of persons
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/race.sql",
                                    packageName = "Achilles",
                                    dbms = dbms,
                                    cdmSchema = cdmSchema
  )
  raceData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$RACE_DATA = raceData
  
  # 4.  Title: Ethnicity distribution
  # a.  Visualization: Pie
  # b.	Category: Ethnicity
  # c.	Value: % of persons
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/ethnicity.sql",
                                    packageName = "Achilles",
                                    dbms = dbms,
                                    cdmSchema = cdmSchema
  )
  ethnicityData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$ETHNICITY_DATA = ethnicityData
  
  # 5.  Title:  Year of birth distribution
  # a.  Visualization:  Histogram
  # b.	Category: Year of birth
  # c.	Value:  # of persons
  birthYearHist <- {}
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/yearofbirth_stats.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  birthYearStats <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  birthYearHist$MIN = birthYearStats$MIN_VALUE
  birthYearHist$MAX = birthYearStats$MAX_VALUE
  birthYearHist$INTERVAL_SIZE = birthYearStats$INTERVAL_SIZE
  birthYearHist$INTERVALS = (birthYearStats$MAX_VALUE - birthYearStats$MIN_VALUE) / birthYearStats$INTERVAL_SIZE
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/person/yearofbirth_data.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  birthYearData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  birthYearHist$DATA <- birthYearData
  
  output$BIRTH_YEAR_HISTOGRAM <- birthYearHist
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/person.json", sep=""))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)
}

generateObservationPeriodReport <- function(conn, dbms, cdmSchema, outputPath)
{
  writeLines("Generating observation period reports")
  progressBar <- txtProgressBar(max=11,style=3)
  progress = 0
  output = {}
  
  # 1.  Title:  Age at time of first observation
  # a.  Visualization:  Histogram
  # b.  Category: Age
  # c.	Value:  # of persons
  
  ageAtFirstObservationHist <- {}
  
  # stats are hard coded for this result to make x-axis consistent across datasources
  ageAtFirstObservationHist$MIN = 0
  ageAtFirstObservationHist$MAX =100
  ageAtFirstObservationHist$INTERVAL_SIZE = 1
  ageAtFirstObservationHist$INTERVALS = 100
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/ageatfirst.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  ageAtFirstObservationData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  ageAtFirstObservationHist$DATA = ageAtFirstObservationData
  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM <- ageAtFirstObservationHist
  
  # 2.  Title: Age by gender
  # a.	Visualization:  Side-by-side boxplot
  # b.	Category:  Gender
  # c.	Values:  Min/25%/Median/95%/Max  - age at time of first observation
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/agebygender.sql",
                                    packageName = "Achilles",
                                    dbms = dbms,
                                    cdmSchema = cdmSchema
  )
  ageByGenderData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$AGE_BY_GENDER = ageByGenderData
  
  # 3.  Title: Length of observation
  # a.	Visualization:  bar
  # b.	Category:  length of observation period, 30d increments
  # c.	Values: # of persons
  
  observationLengthHist <- {}
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlength_stats.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  
  observationLengthStats <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observationLengthHist$MIN = observationLengthStats$MIN_VALUE
  observationLengthHist$MAX = observationLengthStats$MAX_VALUE
  observationLengthHist$INTERVAL_SIZE = observationLengthStats$INTERVAL_SIZE
  observationLengthHist$INTERVALS = (observationLengthStats$MAX_VALUE - observationLengthStats$MIN_VALUE) / observationLengthStats$INTERVAL_SIZE
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlength_data.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  observationLengthData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observationLengthHist$DATA <- observationLengthData
  
  output$OBSERVATION_LENGTH_HISTOGRAM = observationLengthHist
  
  
  # 4.  Title:  Cumulative duration of observation
  # a.	Visualization:  scatterplot
  # b.	X-axis:  length of observation period
  # c.	Y-axis:  % of population observed
  # d.	Note:  will look like a Kaplan-Meier âsurvivalâ plot, but information is the same as shown in âlength of observationâ barchart, just plotted as cumulative 
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/cumulativeduration.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )  
  
  cumulativeDurationData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$CUMULATIVE_DURATION = cumulativeDurationData
  
  # 5.  Title:  Observation period length distribution, by gender
  # a.	Visualization:  side-by-side boxplot
  # b.	Category: Gender
  # c.	Values: Min/25%/Median/95%/Max  length of observation period
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlengthbygender.sql",
                                    packageName = "Achilles",
                                    dbms = dbms,
                                    cdmSchema = cdmSchema
  )
  opLengthByGenderData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$OBSERVATION_PERIOD_LENGTH_BY_GENDER = opLengthByGenderData
  
  # 6.  Title:  Observation period length distribution, by age
  # a.	Visualization:  side-by-side boxplot
  # b.	Category: Age decile
  # c.	Values: Min/25%/Median/95%/Max  length of observation period
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observationlengthbyage.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  opLengthByAgeData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$OBSERVATION_PERIOD_LENGTH_BY_AGE = opLengthByAgeData
  
  # 7.  Title:  Number of persons with continuous observation by year
  # a.	Visualization:  Histogram
  # b.	Category:  Year
  # c.	Values:  # of persons with continuous coverage
  
  observedByYearHist <- {}
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observedbyyear_stats.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  observedByYearStats <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observedByYearHist$MIN = observedByYearStats$MIN_VALUE
  observedByYearHist$MAX = observedByYearStats$MAX_VALUE
  observedByYearHist$INTERVAL_SIZE = observedByYearStats$INTERVAL_SIZE
  observedByYearHist$INTERVALS = (observedByYearStats$MAX_VALUE - observedByYearStats$MIN_VALUE) / observedByYearStats$INTERVAL_SIZE
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observedbyyear_data.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  
  observedByYearData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observedByYearHist$DATA <- observedByYearData
  
  output$OBSERVED_BY_YEAR_HISTOGRAM = observedByYearHist
  
  # 8.  Title:  Number of persons with continuous observation by month
  # a.	Visualization:  Histogram
  # b.	Category:  Month/year
  # c.	Values:  # of persons with continuous coverage
  
  observedByMonth <- {}
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/observedbymonth.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  observedByMonth <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$OBSERVED_BY_MONTH = observedByMonth
  
  # 9.  Title:  Number of observation periods per person
  # a.	Visualization:  Pie
  # b.	Category:  Number of observation periods
  # c.	Values:  # of persons 
  
  renderedSql <- renderAndTranslate(sqlFilename = "export/observationperiod/periodsperperson.sql",
                                    packageName = "Achilles",
                                    dbms = dbms
  )
  personPeriodsData <- querySql(conn,dbms,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$PERSON_PERIODS_DATA = personPeriodsData
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/observationperiod.json", sep=""))
  close(progressBar)
}

generateDashboardReport <- function(outputPath)
{
  writeLines("Generating dashboard report")
  output <- {}

  progressBar <- txtProgressBar(max=4,style=3)
  progress = 0

  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  personReport <- fromJSON(file = paste(outputPath, "/person.json", sep=""))
  output$SUMMARY <- personReport$SUMMARY
  output$GENDER_DATA <- personReport$GENDER_DATA

  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  opReport <- fromJSON(file = paste(outputPath, "/observationperiod.json", sep=""))
  
  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM = opReport$AGE_AT_FIRST_OBSERVATION_HISTOGRAM
  output$CUMULATIVE_DURATION = opReport$CUMULATIVE_DURATION
  output$OBSERVED_BY_MONTH = opReport$OBSERVED_BY_MONTH
  
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/dashboard.json", sep=""))  
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)

  close(progressBar)
  
}


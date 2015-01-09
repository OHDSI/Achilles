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

#allReports <- c("CONDITION",
#                "CONDITION_ERA",  
#                "DASHBOARD", 
#                "DATA_DENSITY",
#                "DEATH",
#                "DRUG",
#                "DRUG_ERA",
#                "HEEL",
#                "OBSERVATION",
#                "OBSERVATION_PERIOD",
#                "PERSON", 
#                "PROCEDURE",
#                "VISIT")
#save(allReports,file="allReports.rda")

initOutputPath <- function (outputPath){
  # create output path if it doesn't already exist, warn if it does
  if (file.exists(outputPath)){
    writeLines(paste("Warning: folder",outputPath,"already exists"))
  } else {
    dir.create(paste(outputPath,"/",sep=""))
  }
}

#' @title showReportTypes
#'
#' @description
#' \code{showReportTypes} Displays the Report Types that can be passed as vector values to exportToJson.
#'
#' @details
#' exportToJson supports the following report types:
#' "CONDITION","CONDITION_ERA", "DASHBOARD", "DATA_DENSITY", "DEATH", "DRUG", "DRUG_ERA", "HEEL", "OBSERVATION", "OBSERVATION_PERIOD", "PERSON", "PROCEDURE","VISIT"
#' 
#' @return none (opens the allReports vector in a View() display) 
#' @examples \dontrun{
#'   showReportTypes()
#' }
#' @export
showReportTypes <- function()
{
  View(allReports)
}

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
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' @param reports       A character vector listing the set of reports to generate. Default is all reports. 
#' See \code{data(allReports)} for a list of all report types
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), reports = allReports, cdmVersion = "4")
{
  start <- Sys.time()
  if (missing(resultsSchema))
    resultsSchema <- cdmSchema
  
  initOutputPath(outputPath)
  
  # connect to the results schema
  connectionDetails$schema = resultsSchema
  conn <- connect(connectionDetails)
  
  # generate reports
  
  if ("CONDITION" %in% reports)
  {
    generateConditionTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)  
    generateConditionReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("CONDITION_ERA" %in% reports)
  {
    generateConditionEraTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
    generateConditionEraReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("DATA_DENSITY" %in% reports)
    generateDataDensityReport(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  
  if ("DEATH" %in% reports)
  {
    generateDeathReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("DRUG_ERA" %in% reports)
  {
    generateDrugEraTreemap(conn,connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
    generateDrugEraReports(conn,connectionDetails$dbms,cdmSchema,outputPath, cdmVersion)
  }
  
  if ("DRUG" %in% reports)
  {
    generateDrugTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)  
    generateDrugReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("HEEL" %in% reports)
  {
    generateAchillesHeelReport(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("OBSERVATION" %in% reports)
  {  
    generateObservationTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
    generateObservationReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("OBSERVATION_PERIOD" %in% reports)  
    generateObservationPeriodReport(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  
  if ("PERSON" %in% reports)    
    generatePersonReport(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  
  if ("PROCEDURE" %in% reports)
  {
    generateProcedureTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
    generateProcedureReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  if ("VISIT" %in% reports)
  {  
    generateVisitTreemap(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
    generateVisitReports(conn, connectionDetails$dbms, cdmSchema, outputPath, cdmVersion)
  }
  
  # dashboard is always last
  if ("DASHBOARD" %in% reports)
  {
    generateDashboardReport(outputPath)
  }
  
  dummy <- dbDisconnect(conn)
  
  delta <- Sys.time() - start
  writeLines(paste("Export took", signif(delta,3), attr(delta,"units")))
  writeLines(paste("JSON files can now be found in",outputPath))
}

#' @title exportConditionToJson
#'
#' @description
#' \code{exportConditonToJson} Exports Achilles Condition report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Condition report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportConditionToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportConditionToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("CONDITION"), cdmVersion)  
}

#' @title exportConditionEraToJson
#'
#' @description
#' \code{exportConditionEraToJson} Exports Achilles Condition Era report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Condition Era report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportConditionEraToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportConditionEraToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("CONDITION_ERA"), cdmVersion)  
}

#' @title exportDashboardToJson
#'
#' @description
#' \code{exportDashboardToJson} Exports Achilles Dashboard report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Dashboard report found in Achilles.Web. NOTE: This function reads the results
#' from the other exports and aggregates them into a single file. If other reports are not genreated, this function will fail.
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportDashboardToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportDashboardToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("DASHBOARD"), cdmVersion)  
}

#' @title exportDataDensityToJson
#'
#' @description
#' \code{exportDataDensityToJson} Exports Achilles Data Density report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Data Density report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportDataDensityToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportDataDensityToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("DATA_DENSITY"), cdmVersion)  
}

#' @title exportDeathToJson
#'
#' @description
#' \code{exportDeathToJson} Exports Achilles Death report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Death report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportDeathToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportDeathToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("DEATH"), cdmVersion)  
}

#' @title exportDrugToJson
#'
#' @description
#' \code{exportDrugToJson} Exports Achilles Drug report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Drug report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportDrugToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportDrugToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("DRUG"), cdmVersion)  
}

#' @title exportDrugEraToJson
#'
#' @description
#' \code{exportDrugEraToJson} Exports Achilles Drug Era report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Drug Era report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportDrugEraToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportDrugEraToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("DRUG_ERA"), cdmVersion)  
}

#' @title exportHeelToJson
#'
#' @description
#' \code{exportHeelToJson} Exports Achilles Heel report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Achilles Heel report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportHeelToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportHeelToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("HEEL"), cdmVersion)  
}

#' @title exportObservationToJson
#'
#' @description
#' \code{exportObservationToJson} Exports Achilles Observation report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Observation report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportObservationToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportObservationToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("OBSERVATION"), cdmVersion)  
}

#' @title exportObservationPeriodToJson
#'
#' @description
#' \code{exportObservationPeriodToJson} Exports Achilles Observation Period report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Observation Period report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportObservationPeriodToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportObservationPeriodToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("OBSERVATION_PERIOD"), cdmVersion)  
}

#' @title exportPersonToJson
#'
#' @description
#' \code{exportPersonToJson} Exports Achilles Person report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Person report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema    	Name of the database schema that contains the vocabulary files
#' @param resultsSchema			Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportPersonToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportPersonToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("PERSON"), cdmVersion)  
}

#' @title exportProcedureToJson
#'
#' @description
#' \code{exportProcedureToJson} Exports Achilles Procedure report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Procedure report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportProcedureToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportProcedureToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("PROCEDURE"), cdmVersion)  
}

#' @title exportVisitToJson
#'
#' @description
#' \code{exportVisitToJson} Exports Achilles Visit report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Visit report found in Achilles.Web
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema      Name of the database schema that contains the vocabulary files
#' @param resultsSchema  		Name of the database schema that contains the Achilles analysis files. Default is cdmSchema
#' @param outputPath		A folder location to save the JSON files. Default is current working folder
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportVisitToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportVisitToJson <- function (connectionDetails, cdmSchema, resultsSchema, outputPath = getwd(), cdmVersion="4")
{
  exportToJson(connectionDetails, cdmSchema, resultsSchema, outputPath, reports = c("VISIT"), cdmVersion)  
}

addCdmVersionPath <- function(sqlFilename,cdmVersion){
  if (cdmVersion == "4") {
    sqlFolder <- "export_v4"
  } else if (cdmVersion == "5") {
    sqlFolder <- "export_v5"
  } else {
    stop("Error: Invalid CDM Version number, use 4 or 5")
  }
  paste(sqlFolder,sqlFilename,sep="")
}

generateAchillesHeelReport <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating achilles heel report")
  output <- {}
  
  queryAchillesHeel <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/achillesheel/sqlAchillesHeel.sql",cdmVersion),
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )  
  
  output$MESSAGES <- querySql(conn,queryAchillesHeel)
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/achillesheel.json", sep=""))  
}

generateDrugEraTreemap <- function(conn, dbms,cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating drug era treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryDrugEraTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drugera/sqlDrugEraTreemap.sql",cdmVersion),
                                                packageName = "Achilles",
                                                dbms = dbms,
                                                cdmSchema = cdmSchema
  )  
  
  dataDrugEraTreemap <- querySql(conn,queryDrugEraTreemap) 
  
  write(toJSON(dataDrugEraTreemap,method="C"),paste(outputPath, "/drugera_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)  
}

generateDrugTreemap <- function(conn, dbms,cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating drug treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryDrugTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlDrugTreemap.sql",cdmVersion),
                                             packageName = "Achilles",
                                             dbms = dbms,
                                             cdmSchema = cdmSchema
  )  
  
  dataDrugTreemap <- querySql(conn,queryDrugTreemap) 
  
  write(toJSON(dataDrugTreemap,method="C"),paste(outputPath, "/drug_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)  
}

generateConditionTreemap <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating condition treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryConditionTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/condition/sqlConditionTreemap.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )  
  
  dataConditionTreemap <- querySql(conn,queryConditionTreemap) 
  
  write(toJSON(dataConditionTreemap,method="C"),paste(outputPath, "/condition_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)
}

generateConditionEraTreemap <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating condition era treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryConditionEraTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/conditionera/sqlConditionEraTreemap.sql",cdmVersion),
                                                     packageName = "Achilles",
                                                     dbms = dbms,
                                                     cdmSchema = cdmSchema
  )  
  
  dataConditionEraTreemap <- querySql(conn,queryConditionEraTreemap) 
  
  write(toJSON(dataConditionEraTreemap,method="C"),paste(outputPath, "/conditionera_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)
}

generateConditionReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating condition reports")
  
  treemapFile <- file.path(outputPath,"condition_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  
  conditionsFolder <- file.path(outputPath,"conditions")
  if (file.exists(conditionsFolder)){
    writeLines(paste("Warning: folder ",conditionsFolder," already exists"))
  } else {
    dir.create(paste(conditionsFolder,"/",sep=""))
    
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/condition/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/condition/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryConditionsByType <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/condition/sqlConditionsByType.sql",cdmVersion),
                                                  packageName = "Achilles",
                                                  dbms = dbms,
                                                  cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstDiagnosis <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/condition/sqlAgeAtFirstDiagnosis.sql",cdmVersion),
                                                     packageName = "Achilles",
                                                     dbms = dbms,
                                                     cdmSchema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)  
  dataConditionsByType <- querySql(conn,queryConditionsByType)    
  dataAgeAtFirstDiagnosis <- querySql(conn,queryAgeAtFirstDiagnosis)    
  
  
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

generateConditionEraReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating condition era reports")
  
  treemapFile <- file.path(outputPath,"conditionera_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  conditionsFolder <- file.path(outputPath,"conditioneras")
  if (file.exists(conditionsFolder)){
    writeLines(paste("Warning: folder ",conditionsFolder," already exists"))
  } else {
    dir.create(paste(conditionsFolder,"/",sep=""))
    
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/conditionera/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/conditionera/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstDiagnosis <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/conditionera/sqlAgeAtFirstDiagnosis.sql",cdmVersion),
                                                     packageName = "Achilles",
                                                     dbms = dbms,
                                                     cdmSchema = cdmSchema
  )
  
  queryLengthOfEra <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/conditionera/sqlLengthOfEra.sql",cdmVersion),
                                             packageName = "Achilles",
                                             dbms = dbms,
                                             cdmSchema = cdmSchema
  )  
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)  
  dataLengthOfEra <- querySql(conn,queryLengthOfEra)    
  dataAgeAtFirstDiagnosis <- querySql(conn,queryAgeAtFirstDiagnosis)    
  
  
  buildConditionEraReport <- function(concept_id) {
    report <- {}
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(2,3,4,5)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(2,3)]
    report$LENGTH_OF_ERA <- dataLengthOfEra[dataLengthOfEra$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$AGE_AT_FIRST_DIAGNOSIS <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    filename <- paste(outputPath, "/conditioneras/condition_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildConditionEraReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateDrugEraReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating drug era reports")
  
  
  treemapFile <- file.path(outputPath,"drugera_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  
  drugerasFolder <- file.path(outputPath,"drugeras")
  if (file.exists(drugerasFolder)){
    writeLines(paste("Warning: folder ",drugerasFolder," already exists"))
  } else {
    dir.create(paste(drugerasFolder,"/",sep=""))
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryAgeAtFirstExposure <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drugera/sqlAgeAtFirstExposure.sql",cdmVersion),
                                                    packageName = "Achilles",
                                                    dbms = dbms,
                                                    cdmSchema = cdmSchema
  )
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drugera/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drugera/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryLengthOfEra <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drugera/sqlLengthOfEra.sql",cdmVersion),
                                             packageName = "Achilles",
                                             dbms = dbms,
                                             cdmSchema = cdmSchema
  )
  
  dataAgeAtFirstExposure <- querySql(conn,queryAgeAtFirstExposure) 
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)
  dataLengthOfEra <- querySql(conn,queryLengthOfEra)
  
  buildDrugEraReport <- function(concept_id) {
    report <- {}
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(2,3,4,5)]  
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(2,3)]
    report$LENGTH_OF_ERA <- dataLengthOfEra[dataLengthOfEra$CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    
    filename <- paste(outputPath, "/drugeras/drug_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildDrugEraReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateDrugReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating drug reports")
  
  treemapFile <- file.path(outputPath,"drug_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  drugsFolder <- file.path(outputPath,"drugs")
  if (file.exists(drugsFolder)){
    writeLines(paste("Warning: folder ",drugsFolder," already exists"))
  } else {
    dir.create(paste(drugsFolder,"/",sep=""))
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryAgeAtFirstExposure <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlAgeAtFirstExposure.sql",cdmVersion),
                                                    packageName = "Achilles",
                                                    dbms = dbms,
                                                    cdmSchema = cdmSchema
  )
  
  queryDaysSupplyDistribution <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlDaysSupplyDistribution.sql",cdmVersion),
                                                        packageName = "Achilles",
                                                        dbms = dbms,
                                                        cdmSchema = cdmSchema
  )
  
  queryDrugsByType <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlDrugsByType.sql",cdmVersion),
                                             packageName = "Achilles",
                                             dbms = dbms,
                                             cdmSchema = cdmSchema
  )
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryQuantityDistribution <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlQuantityDistribution.sql",cdmVersion),
                                                      packageName = "Achilles",
                                                      dbms = dbms,
                                                      cdmSchema = cdmSchema
  )
  
  queryRefillsDistribution <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/drug/sqlRefillsDistribution.sql",cdmVersion),
                                                     packageName = "Achilles",
                                                     dbms = dbms,
                                                     cdmSchema = cdmSchema
  )
  
  dataAgeAtFirstExposure <- querySql(conn,queryAgeAtFirstExposure) 
  dataDaysSupplyDistribution <- querySql(conn,queryDaysSupplyDistribution) 
  dataDrugsByType <- querySql(conn,queryDrugsByType) 
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)
  dataQuantityDistribution <- querySql(conn,queryQuantityDistribution) 
  dataRefillsDistribution <- querySql(conn,queryRefillsDistribution) 
  
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

generateProcedureTreemap <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating procedure treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryProcedureTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/procedure/sqlProcedureTreemap.sql",cdmVersion),
                                                  packageName = "Achilles",
                                                  dbms = dbms,
                                                  cdmSchema = cdmSchema
  )  
  
  dataProcedureTreemap <- querySql(conn,queryProcedureTreemap) 
  
  write(toJSON(dataProcedureTreemap,method="C"),paste(outputPath, "/procedure_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)
}

generateProcedureReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating procedure reports")
  
  treemapFile <- file.path(outputPath,"procedure_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  proceduresFolder <- file.path(outputPath,"procedures")
  if (file.exists(proceduresFolder)){
    writeLines(paste("Warning: folder ",proceduresFolder," already exists"))
  } else {
    dir.create(paste(proceduresFolder,"/",sep=""))
    
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/procedure/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/procedure/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryProceduresByType <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/procedure/sqlProceduresByType.sql",cdmVersion),
                                                  packageName = "Achilles",
                                                  dbms = dbms,
                                                  cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstOccurrence <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/procedure/sqlAgeAtFirstOccurrence.sql",cdmVersion),
                                                      packageName = "Achilles",
                                                      dbms = dbms,
                                                      cdmSchema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)  
  dataProceduresByType <- querySql(conn,queryProceduresByType)    
  dataAgeAtFirstOccurrence <- querySql(conn,queryAgeAtFirstOccurrence)    
  
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

generatePersonReport <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4")
{
  writeLines("Generating person reports")
  progressBar <- txtProgressBar(max=7,style=3)
  progress = 0
  output = {}
  
  # 1.  Title:  Population
  # a.  Visualization: Table
  # b.	Row #1:  CDM source name
  # c.	Row #2:  # of persons
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/person/population.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  
  personSummaryData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$SUMMARY = personSummaryData
  
  # 2.  Title:  Gender distribution
  # a.   Visualization: Pie
  # b.	Category:  Gender
  # c.	Value:  % of persons  
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/person/gender.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  genderData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$GENDER_DATA = genderData
  
  # 3.  Title: Race distribution
  # a.  Visualization: Pie
  # b.	Category: Race
  # c.	Value: % of persons
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/person/race.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  raceData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$RACE_DATA = raceData
  
  # 4.  Title: Ethnicity distribution
  # a.  Visualization: Pie
  # b.	Category: Ethnicity
  # c.	Value: % of persons
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/person/ethnicity.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  ethnicityData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$ETHNICITY_DATA = ethnicityData
  
  # 5.  Title:  Year of birth distribution
  # a.  Visualization:  Histogram
  # b.	Category: Year of birth
  # c.	Value:  # of persons
  birthYearHist <- {}
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/person/yearofbirth_stats.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  birthYearStats <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  birthYearHist$MIN = birthYearStats$MIN_VALUE
  birthYearHist$MAX = birthYearStats$MAX_VALUE
  birthYearHist$INTERVAL_SIZE = birthYearStats$INTERVAL_SIZE
  birthYearHist$INTERVALS = (birthYearStats$MAX_VALUE - birthYearStats$MIN_VALUE) / birthYearStats$INTERVAL_SIZE
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/person/yearofbirth_data.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  birthYearData <- querySql(conn,renderedSql)
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

generateObservationPeriodReport <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4")
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
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/ageatfirst.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  ageAtFirstObservationData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  ageAtFirstObservationHist$DATA = ageAtFirstObservationData
  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM <- ageAtFirstObservationHist
  
  # 2.  Title: Age by gender
  # a.	Visualization:  Side-by-side boxplot
  # b.	Category:  Gender
  # c.	Values:  Min/25%/Median/95%/Max  - age at time of first observation
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/agebygender.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  ageByGenderData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$AGE_BY_GENDER = ageByGenderData
  
  # 3.  Title: Length of observation
  # a.	Visualization:  bar
  # b.	Category:  length of observation period, 30d increments
  # c.	Values: # of persons
  
  observationLengthHist <- {}
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observationlength_stats.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  
  observationLengthStats <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observationLengthHist$MIN = observationLengthStats$MIN_VALUE
  observationLengthHist$MAX = observationLengthStats$MAX_VALUE
  observationLengthHist$INTERVAL_SIZE = observationLengthStats$INTERVAL_SIZE
  observationLengthHist$INTERVALS = (observationLengthStats$MAX_VALUE - observationLengthStats$MIN_VALUE) / observationLengthStats$INTERVAL_SIZE
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observationlength_data.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  observationLengthData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observationLengthHist$DATA <- observationLengthData
  
  output$OBSERVATION_LENGTH_HISTOGRAM = observationLengthHist
  
  # 4.  Title:  Cumulative duration of observation
  # a.	Visualization:  scatterplot
  # b.	X-axis:  length of observation period
  # c.	Y-axis:  % of population observed
  # d.	Note:  will look like a Kaplan-Meier âsurvivalâ plot, but information is the same as shown in âlength of observationâ barchart, just plotted as cumulative 
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/cumulativeduration.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  cumulativeDurationData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$CUMULATIVE_DURATION = cumulativeDurationData
  
  # 5.  Title:  Observation period length distribution, by gender
  # a.	Visualization:  side-by-side boxplot
  # b.	Category: Gender
  # c.	Values: Min/25%/Median/95%/Max  length of observation period
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observationlengthbygender.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  opLengthByGenderData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$OBSERVATION_PERIOD_LENGTH_BY_GENDER = opLengthByGenderData
  
  # 6.  Title:  Observation period length distribution, by age
  # a.	Visualization:  side-by-side boxplot
  # b.	Category: Age decile
  # c.	Values: Min/25%/Median/95%/Max  length of observation period
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observationlengthbyage.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  opLengthByAgeData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$OBSERVATION_PERIOD_LENGTH_BY_AGE = opLengthByAgeData
  
  # 7.  Title:  Number of persons with continuous observation by year
  # a.	Visualization:  Histogram
  # b.	Category:  Year
  # c.	Values:  # of persons with continuous coverage
  
  observedByYearHist <- {}
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observedbyyear_stats.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  observedByYearStats <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observedByYearHist$MIN = observedByYearStats$MIN_VALUE
  observedByYearHist$MAX = observedByYearStats$MAX_VALUE
  observedByYearHist$INTERVAL_SIZE = observedByYearStats$INTERVAL_SIZE
  observedByYearHist$INTERVALS = (observedByYearStats$MAX_VALUE - observedByYearStats$MIN_VALUE) / observedByYearStats$INTERVAL_SIZE
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observedbyyear_data.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  
  observedByYearData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  observedByYearHist$DATA <- observedByYearData
  
  output$OBSERVED_BY_YEAR_HISTOGRAM = observedByYearHist
  
  # 8.  Title:  Number of persons with continuous observation by month
  # a.	Visualization:  Histogram
  # b.	Category:  Month/year
  # c.	Values:  # of persons with continuous coverage
  
  observedByMonth <- {}
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/observedbymonth.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  observedByMonth <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  output$OBSERVED_BY_MONTH = observedByMonth
  
  # 9.  Title:  Number of observation periods per person
  # a.	Visualization:  Pie
  # b.	Category:  Number of observation periods
  # c.	Values:  # of persons 
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observationperiod/periodsperperson.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )
  personPeriodsData <- querySql(conn,renderedSql)
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

generateDataDensityReport <- function(conn, dbms,cdmSchema, outputPath, cdmVersion = "4")
{
  writeLines("Generating data density reports")
  progressBar <- txtProgressBar(max=3,style=3)
  progress = 0
  output = {}
  
  #   1.  Title: Total records
  #   a.	Visualization: scatterplot
  #   b.	X-axis:  month/year
  #   c.	y-axis:  records
  #   d.	series:  person, visit, condition, drug, procedure, observation
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/datadensity/totalrecords.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  totalRecordsData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$TOTAL_RECORDS = totalRecordsData
  
  #   2.  Title: Records per person
  #   a.	Visualization: scatterplot
  #   b.	X-axis:  month/year
  #   c.	y-axis:  records/person
  #   d.	series:  person, visit, condition, drug, procedure, observation
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/datadensity/recordsperperson.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  recordsPerPerson <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$RECORDS_PER_PERSON = recordsPerPerson
  
  #   3.  Title:  Concepts per person
  #   a.	Visualization: side-by-side boxplot
  #   b.	Category: Condition/Drug/Procedure/Observation
  #   c.	Values: Min/25%/Median/95%/Max  number of distinct concepts per person
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/datadensity/conceptsperperson.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  conceptsPerPerson <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$CONCEPTS_PER_PERSON = conceptsPerPerson
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/datadensity.json", sep=""))
  close(progressBar)
  
}

generateObservationTreemap <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4") {
  writeLines("Generating observation treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryObservationTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlObservationTreemap.sql",cdmVersion),
                                                    packageName = "Achilles",
                                                    dbms = dbms,
                                                    cdmSchema = cdmSchema
  )
  
  dataObservationTreemap <- querySql(conn,queryObservationTreemap) 
  
  write(toJSON(dataObservationTreemap,method="C"),paste(outputPath, "/observation_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)  
  
}

generateObservationReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4")
{
  writeLines("Generating Observation reports")
  
  treemapFile <- file.path(outputPath,"observation_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  observationsFolder <- file.path(outputPath,"observations")
  if (file.exists(observationsFolder)){
    writeLines(paste("Warning: folder ",observationsFolder," already exists"))
  } else {
    dir.create(paste(observationsFolder,"/",sep=""))
    
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryObservationsByType <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlObservationsByType.sql",cdmVersion),
                                                    packageName = "Achilles",
                                                    dbms = dbms,
                                                    cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstOccurrence <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlAgeAtFirstOccurrence.sql",cdmVersion),
                                                      packageName = "Achilles",
                                                      dbms = dbms,
                                                      cdmSchema = cdmSchema
  )
  
  queryRecordsByUnit <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlRecordsByUnit.sql",cdmVersion),
                                               packageName = "Achilles",
                                               dbms = dbms,
                                               cdmSchema = cdmSchema
  )
  
  queryObservationValueDistribution <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlObservationValueDistribution.sql",cdmVersion),
                                                              packageName = "Achilles",
                                                              dbms = dbms,
                                                              cdmSchema = cdmSchema
  )
  
  queryLowerLimitDistribution <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlLowerLimitDistribution.sql",cdmVersion),
                                                        packageName = "Achilles",
                                                        dbms = dbms,
                                                        cdmSchema = cdmSchema
  )
  
  queryUpperLimitDistribution <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlUpperLimitDistribution.sql",cdmVersion),
                                                        packageName = "Achilles",
                                                        dbms = dbms,
                                                        cdmSchema = cdmSchema
  )
  
  queryValuesRelativeToNorm <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/observation/sqlValuesRelativeToNorm.sql",cdmVersion),
                                                      packageName = "Achilles",
                                                      dbms = dbms,
                                                      cdmSchema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)  
  dataObservationsByType <- querySql(conn,queryObservationsByType)    
  dataAgeAtFirstOccurrence <- querySql(conn,queryAgeAtFirstOccurrence)
  dataRecordsByUnit <- querySql(conn,queryRecordsByUnit)
  dataObservationValueDistribution <- querySql(conn,queryObservationValueDistribution)
  dataLowerLimitDistribution <- querySql(conn,queryLowerLimitDistribution)
  dataUpperLimitDistribution <- querySql(conn,queryUpperLimitDistribution)
  dataValuesRelativeToNorm <- querySql(conn,queryValuesRelativeToNorm)
  
  buildObservationReport <- function(concept_id) {
    report <- {}
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$OBSERVATIONS_BY_TYPE <- dataObservationsByType[dataObservationsByType$OBSERVATION_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    
    report$RECORDS_BY_UNIT <- dataRecordsByUnit[dataRecordsByUnit$OBSERVATION_CONCEPT_ID == concept_id,c(4,5)]
    report$OBSERVATION_VALUE_DISTRIBUTION <- dataObservationValueDistribution[dataObservationValueDistribution$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$LOWER_LIMIT_DISTRIBUTION <- dataLowerLimitDistribution[dataLowerLimitDistribution$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$UPPER_LIMIT_DISTRIBUTION <- dataUpperLimitDistribution[dataUpperLimitDistribution$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$VALUES_RELATIVE_TO_NORM <- dataValuesRelativeToNorm[dataValuesRelativeToNorm$OBSERVATION_CONCEPT_ID == concept_id,c(4,5)]
    
    filename <- paste(outputPath, "/observations/observation_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildObservationReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)  
  
}

generateVisitTreemap <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4"){
  writeLines("Generating visit_occurrence treemap")
  progressBar <- txtProgressBar(max=1,style=3)
  progress = 0
  
  queryVisitTreemap <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/visit/sqlVisitTreemap.sql",cdmVersion),
                                              packageName = "Achilles",
                                              dbms = dbms,
                                              cdmSchema = cdmSchema
  )
  
  dataVisitTreemap <- querySql(conn,queryVisitTreemap) 
  
  write(toJSON(dataVisitTreemap,method="C"),paste(outputPath, "/visit_treemap.json", sep=''))
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  
  close(progressBar)  
}

generateVisitReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4"){
  writeLines("Generating visit reports")
  
  treemapFile <- file.path(outputPath,"visit_treemap.json")
  if (!file.exists(treemapFile)){
    writeLines(paste("Warning: treemap file",treemapFile,"does not exist. Skipping detail report generation."))
    return()
  }
  
  treemapData <- fromJSON(file = treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)
  
  visitsFolder <- file.path(outputPath,"visits")
  if (file.exists(visitsFolder)){
    writeLines(paste("Warning: folder ",visitsFolder," already exists"))
  } else {
    dir.create(paste(visitsFolder,"/",sep=""))
    
  }
  
  progressBar <- txtProgressBar(style=3)
  progress = 0
  
  queryPrevalenceByGenderAgeYear <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/visit/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                                           packageName = "Achilles",
                                                           dbms = dbms,
                                                           cdmSchema = cdmSchema
  )
  
  queryPrevalenceByMonth <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/visit/sqlPrevalenceByMonth.sql",cdmVersion),
                                                   packageName = "Achilles",
                                                   dbms = dbms,
                                                   cdmSchema = cdmSchema
  )
  
  queryVisitDurationByType <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/visit/sqlVisitDurationByType.sql",cdmVersion),
                                                     packageName = "Achilles",
                                                     dbms = dbms,
                                                     cdmSchema = cdmSchema
  )
  
  queryAgeAtFirstOccurrence <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/visit/sqlAgeAtFirstOccurrence.sql",cdmVersion),
                                                      packageName = "Achilles",
                                                      dbms = dbms,
                                                      cdmSchema = cdmSchema
  )
  
  dataPrevalenceByGenderAgeYear <- querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- querySql(conn,queryPrevalenceByMonth)  
  dataVisitDurationByType <- querySql(conn,queryVisitDurationByType)    
  dataAgeAtFirstOccurrence <- querySql(conn,queryAgeAtFirstOccurrence)    
  
  buildVisitReport <- function(concept_id) {
    report <- {}
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$VISIT_DURATION_BY_TYPE <- dataVisitDurationByType[dataVisitDurationByType$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    filename <- paste(outputPath, "/visits/visit_" , concept_id , ".json", sep='')  
    
    write(toJSON(report,method="C"),filename)  
    
    #Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal +1 ,envir= env)
    setTxtProgressBar(get("progressBar", envir= env), (curVal + 1) / get("totalCount", envir= env))
  }
  
  dummy <- lapply(uniqueConcepts, buildVisitReport)  
  
  setTxtProgressBar(progressBar, 1)
  close(progressBar)  
}

generateDeathReports <- function(conn, dbms, cdmSchema, outputPath, cdmVersion = "4"){
  writeLines("Generating death reports")
  progressBar <- txtProgressBar(max=4,style=3)
  progress = 0
  output = {}
  
  #   1.  Title:  Prevalence drilldown, prevalence by gender, age, and year
  #   a.	Visualization: trellis lineplot
  #   b.	Trellis category:  age decile
  #   c.	X-axis:  year
  #   d.	y-axis:  condition prevalence (% persons)
  #   e.	series:  male,  female
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/death/sqlPrevalenceByGenderAgeYear.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  prevalenceByGenderAgeYearData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$PREVALENCE_BY_GENDER_AGE_YEAR = prevalenceByGenderAgeYearData
  
  # 2.  Title:  Prevalence by month
  # a.	Visualization: scatterplot
  # b.	X-axis:  month/year
  # c.	y-axis:  % of persons
  # d.	Comment:  plot to show seasonality
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/death/sqlPrevalenceByMonth.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  prevalenceByMonthData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$PREVALENCE_BY_MONTH = prevalenceByMonthData
  
  # 3.  Title:  Death records by type
  # a.	Visualization: pie
  # b.	Category: death type
  # c.	value:  % of records
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/death/sqlDeathByType.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  deathByTypeData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$DEATH_BY_TYPE = deathByTypeData
  
  # 4.  Title:  Age at death
  # a.	Visualization: side-by-side boxplot
  # b.	Category: gender
  # c.	Values: Min/25%/Median/95%/Max  as age at death
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = addCdmVersionPath("/death/sqlAgeAtDeath.sql",cdmVersion),
                                        packageName = "Achilles",
                                        dbms = dbms,
                                        cdmSchema = cdmSchema
  )  
  
  ageAtDeathData <- querySql(conn,renderedSql)
  progress = progress + 1
  setTxtProgressBar(progressBar, progress)
  output$AGE_AT_DEATH = ageAtDeathData
  
  # Convert to JSON and save file result
  jsonOutput = toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/death.json", sep=""))
  close(progressBar)
}

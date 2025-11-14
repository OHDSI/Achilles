# @file exportToJson
#
# Copyright 2023 Observational Health Data Sciences and Informatics
#
# This file is part of Achilles
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @author Observational Health Data Sciences and Informatics
# @author Martijn Schuemie
# @author Patrick Ryan
# @author Vojtech Huser
# @author Chris Knoll
# @author Ajit Londhe
# @author Taha Abdul-Basser


# When adding a new report, append it to inst/csv/export/all_reports.csv

getAllReports <- function() {
  reports <- read.csv(file = system.file("csv", "export", "all_reports.csv", package = "Achilles"),
    stringsAsFactors = FALSE, header = TRUE)$REPORT
  return(reports)
}

initOutputPath <- function(outputPath) {
  # create output path if it doesn't already exist, warn if it does
  if (file.exists(outputPath)) {
    writeLines(paste("Warning: folder", outputPath, "already exists"))
  } else {
    dir.create(paste(outputPath, "/", sep = ""))
  }
}

#' @title
#' showReportTypes
#'
#' @description
#' \code{showReportTypes} Displays the Report Types that can be passed as vector values to
#' exportToJson.
#'
#' @details
#' exportToJson supports the following report types: "CONDITION","CONDITION_ERA", "DASHBOARD",
#' "DATA_DENSITY", "DEATH", "DRUG", "DRUG_ERA", "META", "OBSERVATION", "OBSERVATION_PERIOD", "PERSON",
#' "PROCEDURE","VISIT"
#'
#' @return
#' none (opens the allReports vector in a View() display)
#' @examples
#' \dontrun{
#' showReportTypes()
#' }
#' @export
showReportTypes <- function() {
  utils::View(getAllReports())
}

#' @title
#' exportToJson
#'
#' @description
#' \code{exportToJson} Exports Achilles statistics into a JSON form for reports.
#'
#' @details
#' Creates individual files for each report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the OMOP CDM.
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              A folder location to save the JSON files. Default is current working
#'                                folder
#' @param reports                 A character vector listing the set of reports to generate. Default is
#'                                all reports.
#' @param vocabDatabaseSchema     string name of database schema that contains OMOP Vocabulary. Default
#'                                is cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#' @param compressIntoOneFile     Boolean indicating if the JSON files should be compressed into one
#'                                zip file. Please note that in Windows, the zip application must be
#'                                stored in the system environment, e.g. Sys.setenv("R_ZIPCMD",
#'                                "some_path_to_zip"). Due to recursion, the actual Achilles files and
#'                                folders will be embedded in any parent directories that the source
#'                                folder has. See \code{showReportTypes} for a list of all report types
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportToJson(connectionDetails, cdmDatabaseSchema = "cdm4_sim", outputPath = "your/output/path")
#' }
#' @export
exportToJson <- function(connectionDetails,
                         cdmDatabaseSchema,
                         resultsDatabaseSchema,
                         outputPath,

  reports = getAllReports(), vocabDatabaseSchema = cdmDatabaseSchema, compressIntoOneFile = FALSE) {

  start <- Sys.time()
  if (missing(resultsDatabaseSchema))
    resultsDatabaseSchema <- cdmDatabaseSchema

  initOutputPath(outputPath)

  # connect to the results schema
  connectionDetails$schema <- resultsDatabaseSchema
  conn <- DatabaseConnector::connect(connectionDetails)

  # generate reports

  if ("CONDITION" %in% reports) {
    generateConditionTreemap(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
    generateConditionReports(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
  }

  if ("CONDITION_ERA" %in% reports) {
    generateConditionEraTreemap(conn,
                                connectionDetails$dbms,
                                cdmDatabaseSchema,
                                resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
    generateConditionEraReports(conn,
                                connectionDetails$dbms,
                                cdmDatabaseSchema,
                                resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
  }

  if ("DATA_DENSITY" %in% reports)
    generateDataDensityReport(conn,
                              connectionDetails$dbms,
                              cdmDatabaseSchema,
                              resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)

  if ("DEATH" %in% reports) {
    generateDeathReports(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
  }

  if ("DRUG_ERA" %in% reports) {
    generateDrugEraTreemap(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
    generateDrugEraReports(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
  }

  if ("DRUG" %in% reports) {
    generateDrugTreemap(conn,
                        connectionDetails$dbms,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema,
                        outputPath,

      vocabDatabaseSchema)
    generateDrugReports(conn,
                        connectionDetails$dbms,
                        cdmDatabaseSchema,
                        resultsDatabaseSchema,
                        outputPath,

      vocabDatabaseSchema)
  }

  if (("META" %in% reports)) {
    generateMetadataReport(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
    generateCdmSourceReport(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
  }

  if (("MEASUREMENT" %in% reports)) {
    generateMeasurementTreemap(conn,
                               connectionDetails$dbms,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
    generateMeasurementReports(conn,
                               connectionDetails$dbms,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
  }


  if ("OBSERVATION" %in% reports) {
    generateObservationTreemap(conn,
                               connectionDetails$dbms,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
    generateObservationReports(conn,
                               connectionDetails$dbms,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
  }

  if ("OBSERVATION_PERIOD" %in% reports)
    generateObservationPeriodReport(conn,
                                    connectionDetails$dbms,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)

  if ("PERSON" %in% reports)
    generatePersonReport(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)

  if ("PROCEDURE" %in% reports) {
    generateProcedureTreemap(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
    generateProcedureReports(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
  }

  if ("VISIT" %in% reports) {
    generateVisitTreemap(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
    generateVisitReports(conn, connectionDetails$dbms, cdmDatabaseSchema, resultsDatabaseSchema,
      outputPath, vocabDatabaseSchema)
  }

  if ("VISIT_DETAIL" %in% reports) {
    generateVisitDetailTreemap(conn,
                               connectionDetails$dbms,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
    generateVisitDetailReports(conn,
                               connectionDetails$dbms,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
  }

  if ("PERFORMANCE" %in% reports) {
    generateAchillesPerformanceReport(conn,
                                      connectionDetails$dbms,
                                      cdmDatabaseSchema,
                                      resultsDatabaseSchema,

      outputPath, vocabDatabaseSchema)
  }

  # dashboard is always last
  if ("DASHBOARD" %in% reports) {
    generateDashboardReport(outputPath)
  }

  DatabaseConnector::disconnect(conn)

  if (compressIntoOneFile) {
    zip(zipfile = file.path(outputPath,
                            sprintf("%s.zip", cdmDatabaseSchema)), files = c(outputPath),
      flags = c("-r"))
  }

  delta <- Sys.time() - start
  writeLines(paste("Export took", signif(delta, 3), attr(delta, "units")))
  writeLines(paste("JSON files can now be found in", outputPath))
}

#' @title
#' exportConditionToJson
#'
#' @description
#' \code{exportConditonToJson} Exports Achilles Condition report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Condition report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportConditionToJson(connectionDetails,
#'                       cdmDatabaseSchema = "cdm4_sim",
#'                       outputPath = "your/output/path")
#' }
#' @export
exportConditionToJson <- function(connectionDetails,
                                  cdmDatabaseSchema,
                                  resultsDatabaseSchema,
                                  outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("CONDITION"),

    vocabDatabaseSchema)
}

#' @title
#' exportConditionEraToJson
#'
#' @description
#' \code{exportConditionEraToJson} Exports Achilles Condition Era report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Condition Era report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportConditionEraToJson(connectionDetails,
#'                          cdmDatabaseSchema = "cdm4_sim",
#'                          outputPath = "your/output/path")
#' }
#' @export
exportConditionEraToJson <- function(connectionDetails,
                                     cdmDatabaseSchema,
                                     resultsDatabaseSchema,
                                     outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("CONDITION_ERA"),

    vocabDatabaseSchema)
}

#' @title
#' exportDashboardToJson
#'
#' @description
#' \code{exportDashboardToJson} Exports Achilles Dashboard report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Dashboard report found in Achilles.Web. NOTE: This function reads the
#' results from the other exports and aggregates them into a single file. If other reports are not
#' genreated, this function will fail.
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportDashboardToJson(connectionDetails,
#'                       cdmDatabaseSchema = "cdm4_sim",
#'                       outputPath = "your/output/path")
#' }
#' @export
exportDashboardToJson <- function(connectionDetails,
                                  cdmDatabaseSchema,
                                  resultsDatabaseSchema,
                                  outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("DASHBOARD"),

    vocabDatabaseSchema)
}

#' @title
#' exportDataDensityToJson
#'
#' @description
#' \code{exportDataDensityToJson} Exports Achilles Data Density report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Data Density report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportDataDensityToJson(connectionDetails,
#'                         cdmDatabaseSchema = "cdm4_sim",
#'                         outputPath = "your/output/path")
#' }
#' @export
exportDataDensityToJson <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("DATA_DENSITY"),

    vocabDatabaseSchema)
}

#' @title
#' exportDeathToJson
#'
#' @description
#' \code{exportDeathToJson} Exports Achilles Death report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Death report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportDeathToJson(connectionDetails,
#'                   cdmDatabaseSchema = "cdm4_sim",
#'                   outputPath = "your/output/path")
#' }
#' @export
exportDeathToJson <- function(connectionDetails,
                              cdmDatabaseSchema,
                              resultsDatabaseSchema,
                              outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("DEATH"),

    vocabDatabaseSchema)
}

#' @title
#' exportDrugToJson
#'
#' @description
#' \code{exportDrugToJson} Exports Achilles Drug report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Drug report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportDrugToJson(connectionDetails,
#'                  cdmDatabaseSchema = "cdm4_sim",
#'                  outputPath = "your/output/path")
#' }
#' @export
exportDrugToJson <- function(connectionDetails,
                             cdmDatabaseSchema,
                             resultsDatabaseSchema,
                             outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("DRUG"),

    vocabDatabaseSchema)
}

#' @title
#' exportDrugEraToJson
#'
#' @description
#' \code{exportDrugEraToJson} Exports Achilles Drug Era report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Drug Era report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportDrugEraToJson(connectionDetails,
#'                     cdmDatabaseSchema = "cdm4_sim",
#'                     outputPath = "your/output/path")
#' }
#' @export
exportDrugEraToJson <- function(connectionDetails,
                                cdmDatabaseSchema,
                                resultsDatabaseSchema,
                                outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("DRUG_ERA"),

    vocabDatabaseSchema)
}


#' @title
#' exportMetaToJson
#'
#' @description
#' \code{exportMetaToJson} Exports Achilles META report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Achilles META report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportMetaToJson(connectionDetails,
#'                  cdmDatabaseSchema = "cdm4_sim",
#'                  outputPath = "your/output/path")
#' }
#' @export
exportMetaToJson <- function(connectionDetails,
                             cdmDatabaseSchema,
                             resultsDatabaseSchema,
                             outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("META"),

    vocabDatabaseSchema)
}

#' @title
#' exportMeasurementToJson
#'
#' @description
#' \code{exportMeasurementToJson} Exports Measurement report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Measurement report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportMeasurementToJson(connectionDetails,
#'                         cdmDatabaseSchema = "cdm4_sim",
#'                         outputPath = "your/output/path")
#' }
#' @export
exportMeasurementToJson <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("MEASUREMENT"),

    vocabDatabaseSchema)
}

#' @title
#' exportObservationToJson
#'
#' @description
#' \code{exportObservationToJson} Exports Achilles Observation report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Observation report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportObservationToJson(connectionDetails,
#'                         cdmDatabaseSchema = "cdm4_sim",
#'                         outputPath = "your/output/path")
#' }
#' @export
exportObservationToJson <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("OBSERVATION"),

    vocabDatabaseSchema)
}

#' @title
#' exportObservationPeriodToJson
#'
#' @description
#' \code{exportObservationPeriodToJson} Exports Achilles Observation Period report into a JSON form
#' for reports.
#'
#' @details
#' Creates individual files for Observation Period report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportObservationPeriodToJson(connectionDetails,
#'                               cdmDatabaseSchema = "cdm4_sim",
#'                               outputPath = "your/output/path")
#' }
#' @export
exportObservationPeriodToJson <- function(connectionDetails,
                                          cdmDatabaseSchema,
                                          resultsDatabaseSchema,
                                          outputPath,
                                          vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(
    connectionDetails,
    cdmDatabaseSchema,
    resultsDatabaseSchema,
    outputPath,
    reports = c("OBSERVATION_PERIOD"),
    vocabDatabaseSchema
  )
}

#' @title
#' exportPersonToJson
#'
#' @description
#' \code{exportPersonToJson} Exports Achilles Person report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Person report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   of the database schema that contains the Achilles analysis files.
#'                                Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportPersonToJson(connectionDetails,
#'                    cdmDatabaseSchema = "cdm4_sim",
#'                    outputPath = "your/output/path")
#' }
#' @export
exportPersonToJson <- function(connectionDetails,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,
                               outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("PERSON"),

    vocabDatabaseSchema)
}

#' @title
#' exportProcedureToJson
#'
#' @description
#' \code{exportProcedureToJson} Exports Achilles Procedure report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Procedure report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#'
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportProcedureToJson(connectionDetails,
#'                       cdmDatabaseSchema = "cdm4_sim",
#'                       outputPath = "your/output/path")
#' }
#' @export
exportProcedureToJson <- function(connectionDetails,
                                  cdmDatabaseSchema,
                                  resultsDatabaseSchema,
                                  outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(connectionDetails,
               cdmDatabaseSchema,
               resultsDatabaseSchema,
               outputPath,
               reports = c("PROCEDURE"),

    vocabDatabaseSchema)
}

#' @title
#' exportVisitToJson
#'
#' @description
#' \code{exportVisitToJson} Exports Achilles Visit report into a JSON form for reports.
#'
#' @details
#' Creates individual files for Visit report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportVisitToJson(connectionDetails,
#'                   cdmDatabaseSchema = "cdm4_sim",
#'                   outputPath = "your/output/path")
#' }
#' @export
exportVisitToJson <- function(connectionDetails,
                              cdmDatabaseSchema,
                              resultsDatabaseSchema,
                              outputPath,
                              vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(
    connectionDetails,
    cdmDatabaseSchema,
    resultsDatabaseSchema,
    outputPath,
    reports = c("VISIT"),
    
    vocabDatabaseSchema
  )
}


#' @title
#' exportVisitDetailToJson
#'
#' @description
#' \code{exportVisitDetailToJson} Exports Achilles VISIT_DETAIL report into a JSON form for reports.
#'
#' @details
#' Creates individual files for VISIT_DETAIL report found in Achilles.Web
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportVisitDetailToJson(connectionDetails,
#'                         cdmDatabaseSchema = "cdm4_sim",
#'                         outputPath = "your/output/path")
#' }
#' @export
exportVisitDetailToJson <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    outputPath,
                                    vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(
    connectionDetails,
    cdmDatabaseSchema,
    resultsDatabaseSchema,
    outputPath,
    reports = c("VISIT_DETAIL"),
    vocabDatabaseSchema
  )
}


#' @title
#' exportPerformanceToJson exportPerformanceToJson
#'
#' @description
#' \code{exportPerformanceToJson} Exports Achilles performance report into a JSON form for reports.
#'
#' @details
#' Creates performance report including how long each Achilles result took to generate.
#'
#'
#' @param connectionDetails       An R object of type ConnectionDetail (details for the function that
#'                                contains server info, database type, optionally username/password,
#'                                port)
#' @param cdmDatabaseSchema       Name of the database schema that contains the vocabulary files
#' @param resultsDatabaseSchema   Name of the database schema that contains the Achilles analysis
#'                                files. Default is cdmDatabaseSchema
#' @param outputPath              folder location to save the JSON files. Default is current working
#'                                folder
#' @param vocabDatabaseSchema     name of database schema that contains OMOP Vocabulary. Default is
#'                                cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#'
#' @return
#' none
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' exportPerformanceToJson(connectionDetails,
#'                         cdmDatabaseSchema = "cdm4_sim",
#'                         outputPath = "your/output/path")
#' }
#' @export
exportPerformanceToJson <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    outputPath,
                                    vocabDatabaseSchema = cdmDatabaseSchema) {
  exportToJson(
    connectionDetails,
    cdmDatabaseSchema,
    resultsDatabaseSchema,
    outputPath,
    reports = c("PERFORMANCE"),
    
    vocabDatabaseSchema
  )
}


generateAchillesPerformanceReport <- function(conn,
                                              dbms,
                                              cdmDatabaseSchema,
                                              resultsDatabaseSchema,
                                              outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating achilles performance report")
  output <- {
  }

  queryAchillesPerformance <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/performance/sqlAchillesPerformance.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  output$MESSAGES <- DatabaseConnector::querySql(conn, queryAchillesPerformance)
  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/achillesperformance.json", sep = ""))
}

generateMetadataReport <- function(conn, dbms, cdmDatabaseSchema, resultsDatabaseSchema, outputPath,
  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating metadata report")
  output <- {
  }

  queryMetadata <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/metadata/sqlMetadata.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema)

  if ("METADATA" %in% DatabaseConnector::getTableNames(connection = conn, databaseSchema = cdmDatabaseSchema)) {
    output$MESSAGES <- DatabaseConnector::querySql(conn, queryMetadata)
    jsonOutput <- jsonlite::toJSON(output)
    write(jsonOutput, file = paste(outputPath, "/metadata.json", sep = ""))
  } else {
    writeLines("No METADATA table found, skipping export")
  }
}

generateCdmSourceReport <- function(conn,
                                    dbms,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating cdm source report")
  output <- {
  }

  queryCdmSource <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/metadata/sqlCdmSource.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema)

  if ("CDM_SOURCE" %in% DatabaseConnector::getTableNames(connection = conn, databaseSchema = cdmDatabaseSchema)) {
    output$MESSAGES <- DatabaseConnector::querySql(conn, queryCdmSource)
    jsonOutput <- jsonlite::toJSON(output)
    write(jsonOutput, file = paste(outputPath, "/cdm_source.json", sep = ""))
  } else {
    writeLines("No CDM_SOURCE table found, skipping export")
  }
}

generateDrugEraTreemap <- function(conn, dbms, cdmDatabaseSchema, resultsDatabaseSchema, outputPath,
  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating drug era treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryDrugEraTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drugera/sqlDrugEraTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataDrugEraTreemap <- DatabaseConnector::querySql(conn, queryDrugEraTreemap)

  write(jsonlite::toJSON(dataDrugEraTreemap, method = "C"), paste(outputPath, "/drugera_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateDrugTreemap <- function(conn,
                                dbms,
                                cdmDatabaseSchema,
                                resultsDatabaseSchema,
                                outputPath,
                                vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating drug treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryDrugTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlDrugTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataDrugTreemap <- DatabaseConnector::querySql(conn, queryDrugTreemap)

  write(jsonlite::toJSON(dataDrugTreemap, method = "C"),
        paste(outputPath, "/drug_treemap.json", sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateConditionTreemap <- function(conn,
                                     dbms,
                                     cdmDatabaseSchema,
                                     resultsDatabaseSchema,
                                     outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating condition treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryConditionTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlConditionTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataConditionTreemap <- DatabaseConnector::querySql(conn, queryConditionTreemap)

  write(jsonlite::toJSON(dataConditionTreemap, method = "C"),
        paste(outputPath, "/condition_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateConditionEraTreemap <- function(conn,
                                        dbms,
                                        cdmDatabaseSchema,
                                        resultsDatabaseSchema,
                                        outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating condition era treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryConditionEraTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/conditionera/sqlConditionEraTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataConditionEraTreemap <- DatabaseConnector::querySql(conn, queryConditionEraTreemap)

  write(jsonlite::toJSON(dataConditionEraTreemap, method = "C"),
        paste(outputPath, "/conditionera_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateConditionReports <- function(conn,
                                     dbms,
                                     cdmDatabaseSchema,
                                     resultsDatabaseSchema,
                                     outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating condition reports")

  treemapFile <- file.path(outputPath, "condition_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)


  conditionsFolder <- file.path(outputPath, "conditions")
  if (file.exists(conditionsFolder)) {
    writeLines(paste("Warning: folder ", conditionsFolder, " already exists"))
  } else {
    dir.create(paste(conditionsFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryConditionsByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlConditionsByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstDiagnosis <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlAgeAtFirstDiagnosis.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataConditionsByType <- DatabaseConnector::querySql(conn, queryConditionsByType)
  dataAgeAtFirstDiagnosis <- DatabaseConnector::querySql(conn, queryAgeAtFirstDiagnosis)


  buildConditionReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$CONDITIONS_BY_TYPE <- dataConditionsByType[dataConditionsByType$CONDITION_CONCEPT_ID ==
      concept_id, c(2, 3)]
    report$AGE_AT_FIRST_DIAGNOSIS <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    filename <- paste(outputPath, "/conditions/condition_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildConditionReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateConditionEraReports <- function(conn,
                                        dbms,
                                        cdmDatabaseSchema,
                                        resultsDatabaseSchema,
                                        outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating condition era reports")

  treemapFile <- file.path(outputPath, "conditionera_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  conditionsFolder <- file.path(outputPath, "conditioneras")
  if (file.exists(conditionsFolder)) {
    writeLines(paste("Warning: folder ", conditionsFolder, " already exists"))
  } else {
    dir.create(paste(conditionsFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/conditionera/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/conditionera/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstDiagnosis <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/conditionera/sqlAgeAtFirstDiagnosis.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryLengthOfEra <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/conditionera/sqlLengthOfEra.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataLengthOfEra <- DatabaseConnector::querySql(conn, queryLengthOfEra)
  dataAgeAtFirstDiagnosis <- DatabaseConnector::querySql(conn, queryAgeAtFirstDiagnosis)


  buildConditionEraReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(2, 3)]
    report$LENGTH_OF_ERA <- dataLengthOfEra[dataLengthOfEra$CONCEPT_ID == concept_id, c(2, 3, 4,
      5, 6, 7, 8, 9)]
    report$AGE_AT_FIRST_DIAGNOSIS <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    filename <- paste(outputPath, "/conditioneras/condition_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildConditionEraReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateDrugEraReports <- function(conn, dbms, cdmDatabaseSchema, resultsDatabaseSchema, outputPath,
  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating drug era reports")


  treemapFile <- file.path(outputPath, "drugera_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)


  drugerasFolder <- file.path(outputPath, "drugeras")
  if (file.exists(drugerasFolder)) {
    writeLines(paste("Warning: folder ", drugerasFolder, " already exists"))
  } else {
    dir.create(paste(drugerasFolder, "/", sep = ""))
  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryAgeAtFirstExposure <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drugera/sqlAgeAtFirstExposure.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drugera/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drugera/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryLengthOfEra <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drugera/sqlLengthOfEra.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn, queryAgeAtFirstExposure)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataLengthOfEra <- DatabaseConnector::querySql(conn, queryLengthOfEra)

  buildDrugEraReport <- function(concept_id) {
    report <- {
    }
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$CONCEPT_ID == concept_id,
      c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(2, 3)]
    report$LENGTH_OF_ERA <- dataLengthOfEra[dataLengthOfEra$CONCEPT_ID == concept_id, c(2, 3, 4,
      5, 6, 7, 8, 9)]

    filename <- paste(outputPath, "/drugeras/drug_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildDrugEraReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateDrugReports <- function(conn,
                                dbms,
                                cdmDatabaseSchema,
                                resultsDatabaseSchema,
                                outputPath,
                                vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating drug reports")

  treemapFile <- file.path(outputPath, "drug_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  drugsFolder <- file.path(outputPath, "drugs")
  if (file.exists(drugsFolder)) {
    writeLines(paste("Warning: folder ", drugsFolder, " already exists"))
  } else {
    dir.create(paste(drugsFolder, "/", sep = ""))
  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryAgeAtFirstExposure <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlAgeAtFirstExposure.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryDaysSupplyDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlDaysSupplyDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryDrugsByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlDrugsByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryDrugFrequencyDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlFrequencyDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryQuantityDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlQuantityDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryRefillsDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlRefillsDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn, queryAgeAtFirstExposure)
  dataDaysSupplyDistribution <- DatabaseConnector::querySql(conn, queryDaysSupplyDistribution)
  dataDrugsByType <- DatabaseConnector::querySql(conn, queryDrugsByType)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataQuantityDistribution <- DatabaseConnector::querySql(conn, queryQuantityDistribution)
  dataRefillsDistribution <- DatabaseConnector::querySql(conn, queryRefillsDistribution)
  dataDrugFrequencyDistribution <- DatabaseConnector::querySql(conn, queryDrugFrequencyDistribution)

  buildDrugReport <- function(concept_id) {
    report <- {
    }
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$DRUG_CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$DAYS_SUPPLY_DISTRIBUTION <- dataDaysSupplyDistribution[dataDaysSupplyDistribution$DRUG_CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$DRUGS_BY_TYPE <- dataDrugsByType[dataDrugsByType$DRUG_CONCEPT_ID == concept_id, c(3, 4)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$DRUG_FREQUENCY_DISTRIBUTION <- dataDrugFrequencyDistribution[dataDrugFrequencyDistribution$CONCEPT_ID ==
      concept_id, c(3, 4)]
    report$QUANTITY_DISTRIBUTION <- dataQuantityDistribution[dataQuantityDistribution$DRUG_CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$REFILLS_DISTRIBUTION <- dataRefillsDistribution[dataRefillsDistribution$DRUG_CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]

    filename <- paste(outputPath, "/drugs/drug_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildDrugReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateProcedureTreemap <- function(conn,
                                     dbms,
                                     cdmDatabaseSchema,
                                     resultsDatabaseSchema,
                                     outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating procedure treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryProcedureTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlProcedureTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataProcedureTreemap <- DatabaseConnector::querySql(conn, queryProcedureTreemap)

  write(jsonlite::toJSON(dataProcedureTreemap, method = "C"),
        paste(outputPath, "/procedure_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateProcedureReports <- function(conn,
                                     dbms,
                                     cdmDatabaseSchema,
                                     resultsDatabaseSchema,
                                     outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating procedure reports")

  treemapFile <- file.path(outputPath, "procedure_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  proceduresFolder <- file.path(outputPath, "procedures")
  if (file.exists(proceduresFolder)) {
    writeLines(paste("Warning: folder ", proceduresFolder, " already exists"))
  } else {
    dir.create(paste(proceduresFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryProcedureFrequencyDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlFrequencyDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryProceduresByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlProceduresByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataProceduresByType <- DatabaseConnector::querySql(conn, queryProceduresByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)
  dataProcedureFrequencyDistribution <- DatabaseConnector::querySql(conn,
                                                                    queryProcedureFrequencyDistribution)

  buildProcedureReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$PROCEDURE_FREQUENCY_DISTRIBUTION <- dataProcedureFrequencyDistribution[dataProcedureFrequencyDistribution$CONCEPT_ID ==
      concept_id, c(3, 4)]
    report$PROCEDURES_BY_TYPE <- dataProceduresByType[dataProceduresByType$PROCEDURE_CONCEPT_ID ==
      concept_id, c(4, 5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    filename <- paste(outputPath, "/procedures/procedure_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildProcedureReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generatePersonReport <- function(conn,
                                 dbms,
                                 cdmDatabaseSchema,
                                 resultsDatabaseSchema,
                                 outputPath,
                                 vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating person reports")
  progressBar <- utils::txtProgressBar(max = 7, style = 3)
  progress <- 0
  output <- {
  }

  # 1.  Title: Population a.  Visualization: Table b.Row #1: CDM source name c.Row #2: # of persons

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/person/population.sql",
                                                   packageName = "Achilles",

    dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema, results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema)

  personSummaryData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  output$SUMMARY <- personSummaryData

  # 2.  Title: Gender distribution a.  Visualization: Pie b.Category: Gender c.Value: % of persons

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/person/gender.sql",
                                                   packageName = "Achilles",

    dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema, results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema)
  genderData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  output$GENDER_DATA <- genderData

  # 3.  Title: Race distribution a.  Visualization: Pie b.Category: Race c.Value: % of persons

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/person/race.sql",
                                                   packageName = "Achilles",

    dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema, results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema)
  raceData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  output$RACE_DATA <- raceData

  # 4.  Title: Ethnicity distribution a.  Visualization: Pie b.Category: Ethnicity c.Value: % of
  # persons

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/person/ethnicity.sql",
                                                   packageName = "Achilles",

    dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema, results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema)
  ethnicityData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  output$ETHNICITY_DATA <- ethnicityData

  # 5.  Title: Year of birth distribution a.  Visualization: Histogram b.Category: Year of birth
  # c.Value: # of persons
  birthYearHist <- {
  }

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/person/yearofbirth_stats.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  birthYearStats <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  birthYearHist$MIN <- birthYearStats$MIN_VALUE
  birthYearHist$MAX <- birthYearStats$MAX_VALUE
  birthYearHist$INTERVAL_SIZE <- birthYearStats$INTERVAL_SIZE
  birthYearHist$INTERVALS <- (birthYearStats$MAX_VALUE - birthYearStats$MIN_VALUE)/birthYearStats$INTERVAL_SIZE

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/person/yearofbirth_data.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  birthYearData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  birthYearHist$DATA <- birthYearData

  output$BIRTH_YEAR_HISTOGRAM <- birthYearHist

  # Convert to JSON and save file result
  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/person.json", sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateObservationPeriodReport <- function(conn,
                                            dbms,
                                            cdmDatabaseSchema,
                                            resultsDatabaseSchema,
                                            outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating observation period reports")
  progressBar <- utils::txtProgressBar(max = 11, style = 3)
  progress <- 0
  output <- {
  }

  # 1.  Title: Age at time of first observation a.  Visualization: Histogram b.  Category: Age
  # c.Value: # of persons

  ageAtFirstObservationHist <- {
  }

  # stats are hard coded for this result to make x-axis consistent across datasources
  ageAtFirstObservationHist$MIN <- 0
  ageAtFirstObservationHist$MAX <- 100
  ageAtFirstObservationHist$INTERVAL_SIZE <- 1
  ageAtFirstObservationHist$INTERVALS <- 100

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/ageatfirst.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  ageAtFirstObservationData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  ageAtFirstObservationHist$DATA <- ageAtFirstObservationData
  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM <- ageAtFirstObservationHist

  # 2.  Title: Age by gender a.Visualization: Side-by-side boxplot b.Category: Gender c.Values:
  # Min/25%/Median/95%/Max - age at time of first observation

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/agebygender.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  ageByGenderData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$AGE_BY_GENDER <- ageByGenderData

  # 3.  Title: Length of observation a.Visualization: bar b.Category: length of observation period,
  # 30d increments c.Values: # of persons

  observationLengthHist <- {
  }

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observationlength_stats.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  observationLengthStats <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  observationLengthHist$MIN <- observationLengthStats$MIN_VALUE
  observationLengthHist$MAX <- observationLengthStats$MAX_VALUE
  observationLengthHist$INTERVAL_SIZE <- observationLengthStats$INTERVAL_SIZE
  observationLengthHist$INTERVALS <- (observationLengthStats$MAX_VALUE - observationLengthStats$MIN_VALUE)/observationLengthStats$INTERVAL_SIZE

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observationlength_data.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  observationLengthData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  observationLengthHist$DATA <- observationLengthData

  output$OBSERVATION_LENGTH_HISTOGRAM <- observationLengthHist

  # 4.  Title: Cumulative duration of observation a.Visualization: scatterplot b.X-axis: length of
  # observation period c.Y-axis: % of population observed d.Note: will look like a Kaplan-Meier
  # survival plot, but information is the same as shown in a length of observation barchart, just
  # plotted as cumulative

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/cumulativeduration.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  cumulativeDurationData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$CUMULATIVE_DURATION <- cumulativeDurationData

  # 5.  Title: Observation period length distribution, by gender a.Visualization: side-by-side
  # boxplot b.Category: Gender c.Values: Min/25%/Median/95%/Max length of observation period

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observationlengthbygender.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  opLengthByGenderData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$OBSERVATION_PERIOD_LENGTH_BY_GENDER <- opLengthByGenderData

  # 6.  Title: Observation period length distribution, by age a.Visualization: side-by-side boxplot
  # b.Category: Age decile c.Values: Min/25%/Median/95%/Max length of observation period

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observationlengthbyage.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  opLengthByAgeData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$OBSERVATION_PERIOD_LENGTH_BY_AGE <- opLengthByAgeData

  # 7.  Title: Number of persons with continuous observation by year a.Visualization: Histogram
  # b.Category: Year c.Values: # of persons with continuous coverage

  observedByYearHist <- {
  }
  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observedbyyear_stats.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  observedByYearStats <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  observedByYearHist$MIN <- observedByYearStats$MIN_VALUE
  observedByYearHist$MAX <- observedByYearStats$MAX_VALUE
  observedByYearHist$INTERVAL_SIZE <- observedByYearStats$INTERVAL_SIZE
  observedByYearHist$INTERVALS <- (observedByYearStats$MAX_VALUE - observedByYearStats$MIN_VALUE)/observedByYearStats$INTERVAL_SIZE

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observedbyyear_data.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  observedByYearData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  observedByYearHist$DATA <- observedByYearData

  output$OBSERVED_BY_YEAR_HISTOGRAM <- observedByYearHist

  # 8.  Title: Number of persons with continuous observation by month a.Visualization: Histogram
  # b.Category: Month/year c.Values: # of persons with continuous coverage

  observedByMonth <- {
  }

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/observedbymonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  observedByMonth <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  output$OBSERVED_BY_MONTH <- observedByMonth

  # 9.  Title: Number of observation periods per person a.Visualization: Pie b.Category: Number of
  # observation periods c.Values: # of persons

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observationperiod/periodsperperson.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)
  personPeriodsData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$PERSON_PERIODS_DATA <- personPeriodsData

  # Convert to JSON and save file result
  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/observationperiod.json", sep = ""))
  close(progressBar)
}

generateDashboardReport <- function(outputPath) {
  writeLines("Generating dashboard report")
  output <- {
  }

  progressBar <- utils::txtProgressBar(max = 4, style = 3)
  progress <- 0

  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  personReport <- jsonlite::fromJSON(paste(outputPath, "/person.json", sep = ""))
  output$SUMMARY <- personReport$SUMMARY
  output$GENDER_DATA <- personReport$GENDER_DATA

  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  opReport <- jsonlite::fromJSON(paste(outputPath, "/observationperiod.json", sep = ""))

  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM <- opReport$AGE_AT_FIRST_OBSERVATION_HISTOGRAM
  output$CUMULATIVE_DURATION <- opReport$CUMULATIVE_DURATION
  output$OBSERVED_BY_MONTH <- opReport$OBSERVED_BY_MONTH

  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/dashboard.json", sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateDataDensityReport <- function(conn,
                                      dbms,
                                      cdmDatabaseSchema,
                                      resultsDatabaseSchema,
                                      outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating data density reports")
  progressBar <- utils::txtProgressBar(max = 3, style = 3)
  progress <- 0
  output <- {
  }

  # 1.  Title: Total records a.Visualization: scatterplot b.X-axis: month/year c.y-axis: records
  # d.series: person, visit, condition, drug, procedure, observation

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/datadensity/totalrecords.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  totalRecordsData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$TOTAL_RECORDS <- totalRecordsData

  # 2.  Title: Records per person a.Visualization: scatterplot b.X-axis: month/year c.y-axis:
  # records/person d.series: person, visit, condition, drug, procedure, observation

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/datadensity/recordsperperson.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  recordsPerPerson <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$RECORDS_PER_PERSON <- recordsPerPerson

  # 3.  Title: Concepts per person a.Visualization: side-by-side boxplot b.Category:
  # Condition/Drug/Procedure/Observation c.Values: Min/25%/Median/95%/Max number of distinct
  # concepts per person

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/datadensity/conceptsperperson.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  conceptsPerPerson <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$CONCEPTS_PER_PERSON <- conceptsPerPerson

  # Convert to JSON and save file result
  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/datadensity.json", sep = ""))
  close(progressBar)

}

generateMeasurementTreemap <- function(conn,
                                       dbms,
                                       cdmDatabaseSchema,
                                       resultsDatabaseSchema,
                                       outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating measurement treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryMeasurementTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlMeasurementTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataMeasurementTreemap <- DatabaseConnector::querySql(conn, queryMeasurementTreemap)

  write(jsonlite::toJSON(dataMeasurementTreemap, method = "C"),
        paste(outputPath, "/measurement_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)

}

generateMeasurementReports <- function(conn,
                                       dbms,
                                       cdmDatabaseSchema,
                                       resultsDatabaseSchema,
                                       outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating Measurement reports")

  treemapFile <- file.path(outputPath, "measurement_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  measurementsFolder <- file.path(outputPath, "measurements")
  if (file.exists(measurementsFolder)) {
    writeLines(paste("Warning: folder ", measurementsFolder, " already exists"))
  } else {
    dir.create(paste(measurementsFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryFrequencyDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlFrequencyDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryMeasurementsByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlMeasurementsByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryRecordsByUnit <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlRecordsByUnit.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryMeasurementValueDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlMeasurementValueDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryLowerLimitDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlLowerLimitDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryUpperLimitDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlUpperLimitDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryValuesRelativeToNorm <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlValuesRelativeToNorm.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataMeasurementsByType <- DatabaseConnector::querySql(conn, queryMeasurementsByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)
  dataRecordsByUnit <- DatabaseConnector::querySql(conn, queryRecordsByUnit)
  dataMeasurementValueDistribution <- DatabaseConnector::querySql(conn,
                                                                  queryMeasurementValueDistribution)
  dataLowerLimitDistribution <- DatabaseConnector::querySql(conn, queryLowerLimitDistribution)
  dataUpperLimitDistribution <- DatabaseConnector::querySql(conn, queryUpperLimitDistribution)
  dataValuesRelativeToNorm <- DatabaseConnector::querySql(conn, queryValuesRelativeToNorm)
  dataFrequencyDistribution <- DatabaseConnector::querySql(conn, queryFrequencyDistribution)

  buildMeasurementReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$FREQUENCY_DISTRIBUTION <- dataFrequencyDistribution[dataFrequencyDistribution$CONCEPT_ID ==
      concept_id, c(3, 4)]
    report$MEASUREMENTS_BY_TYPE <- dataMeasurementsByType[dataMeasurementsByType$MEASUREMENT_CONCEPT_ID ==
      concept_id, c(4, 5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]

    report$RECORDS_BY_UNIT <- dataRecordsByUnit[dataRecordsByUnit$MEASUREMENT_CONCEPT_ID == concept_id,
      c(4, 5)]
    report$MEASUREMENT_VALUE_DISTRIBUTION <- dataMeasurementValueDistribution[dataMeasurementValueDistribution$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$LOWER_LIMIT_DISTRIBUTION <- dataLowerLimitDistribution[dataLowerLimitDistribution$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$UPPER_LIMIT_DISTRIBUTION <- dataUpperLimitDistribution[dataUpperLimitDistribution$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$VALUES_RELATIVE_TO_NORM <- dataValuesRelativeToNorm[dataValuesRelativeToNorm$MEASUREMENT_CONCEPT_ID ==
      concept_id, c(4, 5)]

    filename <- paste(outputPath, "/measurements/measurement_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildMeasurementReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)

}

generateObservationTreemap <- function(conn,
                                       dbms,
                                       cdmDatabaseSchema,
                                       resultsDatabaseSchema,
                                       outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating observation treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryObservationTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observation/sqlObservationTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataObservationTreemap <- DatabaseConnector::querySql(conn, queryObservationTreemap)

  write(jsonlite::toJSON(dataObservationTreemap, method = "C"),
        paste(outputPath, "/observation_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)

}

generateObservationReports <- function(conn,
                                       dbms,
                                       cdmDatabaseSchema,
                                       resultsDatabaseSchema,
                                       outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating Observation reports")

  treemapFile <- file.path(outputPath, "observation_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  observationsFolder <- file.path(outputPath, "observations")
  if (file.exists(observationsFolder)) {
    writeLines(paste("Warning: folder ", observationsFolder, " already exists"))
  } else {
    dir.create(paste(observationsFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observation/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observation/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryObsFrequencyDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observation/sqlFrequencyDistribution.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryObservationsByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observation/sqlObservationsByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/observation/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)


  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataObservationsByType <- DatabaseConnector::querySql(conn, queryObservationsByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)
  dataObsFrequencyDistribution <- DatabaseConnector::querySql(conn, queryObsFrequencyDistribution)


  buildObservationReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$OBS_FREQUENCY_DISTRIBUTION <- dataObsFrequencyDistribution[dataObsFrequencyDistribution$CONCEPT_ID ==
      concept_id, c(3, 4)]
    report$OBSERVATIONS_BY_TYPE <- dataObservationsByType[dataObservationsByType$OBSERVATION_CONCEPT_ID ==
      concept_id, c(4, 5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]


    filename <- paste(outputPath, "/observations/observation_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildObservationReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)

}

generateVisitTreemap <- function(conn,
                                 dbms,
                                 cdmDatabaseSchema,
                                 resultsDatabaseSchema,
                                 outputPath,
                                 vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating visit_occurrence treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryVisitTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visit/sqlVisitTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataVisitTreemap <- DatabaseConnector::querySql(conn, queryVisitTreemap)

  write(jsonlite::toJSON(dataVisitTreemap, method = "C"),
        paste(outputPath, "/visit_treemap.json", sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateVisitReports <- function(conn,
                                 dbms,
                                 cdmDatabaseSchema,
                                 resultsDatabaseSchema,
                                 outputPath,
                                 vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating visit reports")

  treemapFile <- file.path(outputPath, "visit_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  visitsFolder <- file.path(outputPath, "visits")
  if (file.exists(visitsFolder)) {
    writeLines(paste("Warning: folder ", visitsFolder, " already exists"))
  } else {
    dir.create(paste(visitsFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visit/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visit/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryVisitDurationByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visit/sqlVisitDurationByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visit/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataVisitDurationByType <- DatabaseConnector::querySql(conn, queryVisitDurationByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)

  buildVisitReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$VISIT_DURATION_BY_TYPE <- dataVisitDurationByType[dataVisitDurationByType$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    filename <- paste(outputPath, "/visits/visit_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildVisitReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}

generateDeathReports <- function(conn,
                                 dbms,
                                 cdmDatabaseSchema,
                                 resultsDatabaseSchema,
                                 outputPath,
                                 vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating death reports")
  progressBar <- utils::txtProgressBar(max = 4, style = 3)
  progress <- 0
  output <- {
  }

  # 1.  Title: Prevalence drilldown, prevalence by gender, age, and year a.Visualization: trellis
  # lineplot b.Trellis category: age decile c.X-axis: year d.y-axis: condition prevalence (%
  # persons) e.series: male, female

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/death/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  prevalenceByGenderAgeYearData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$PREVALENCE_BY_GENDER_AGE_YEAR <- prevalenceByGenderAgeYearData

  # 2.  Title: Prevalence by month a.Visualization: scatterplot b.X-axis: month/year c.y-axis: % of
  # persons d.Comment: plot to show seasonality

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/death/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  prevalenceByMonthData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$PREVALENCE_BY_MONTH <- prevalenceByMonthData

  # 3.  Title: Death records by type a.Visualization: pie b.Category: death type c.value: % of
  # records

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/death/sqlDeathByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  deathByTypeData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$DEATH_BY_TYPE <- deathByTypeData

  # 4.  Title: Age at death a.Visualization: side-by-side boxplot b.Category: gender c.Values:
  # Min/25%/Median/95%/Max as age at death

  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/death/sqlAgeAtDeath.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  ageAtDeathData <- DatabaseConnector::querySql(conn, renderedSql)
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)
  output$AGE_AT_DEATH <- ageAtDeathData

  # Convert to JSON and save file result
  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/death.json", sep = ""))
  close(progressBar)
}

generateVisitDetailTreemap <- function(conn,
                                       dbms,
                                       cdmDatabaseSchema,
                                       resultsDatabaseSchema,
                                       outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating visit_detail treemap")
  progressBar <- utils::txtProgressBar(max = 1, style = 3)
  progress <- 0

  queryVisitDetailTreemap <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visitdetail/sqlVisitDetailTreemap.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataVisitDetailTreemap <- DatabaseConnector::querySql(conn, queryVisitDetailTreemap)

  write(jsonlite::toJSON(dataVisitDetailTreemap, method = "C"),
        paste(outputPath, "/visitdetail_treemap.json",
    sep = ""))
  progress <- progress + 1
  utils::setTxtProgressBar(progressBar, progress)

  close(progressBar)
}

generateVisitDetailReports <- function(conn,
                                       dbms,
                                       cdmDatabaseSchema,
                                       resultsDatabaseSchema,
                                       outputPath,

  vocabDatabaseSchema = cdmDatabaseSchema) {
  writeLines("Generating visit_detail reports")

  treemapFile <- file.path(outputPath, "visitdetail_treemap.json")
  if (!file.exists(treemapFile)) {
    writeLines(paste("Warning: treemap file",
                     treemapFile,
                     "does not exist. Skipping detail report generation."))
    return()
  }

  treemapData <- jsonlite::fromJSON(treemapFile)
  uniqueConcepts <- unique(treemapData$CONCEPT_ID)
  totalCount <- length(uniqueConcepts)

  visitdetailFolder <- file.path(outputPath, "visitdetail")
  if (file.exists(visitdetailFolder)) {
    writeLines(paste("Warning: folder ", visitdetailFolder, " already exists"))
  } else {
    dir.create(paste(visitdetailFolder, "/", sep = ""))

  }

  progressBar <- utils::txtProgressBar(style = 3)
  progress <- 0

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visitdetail/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visitdetail/sqlPrevalenceByMonth.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryVisitDetailDurationByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visitdetail/sqlVisitDetailDurationByType.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/visitdetail/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles", dbms = dbms, warnOnMissingParameters = FALSE, cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema, vocab_database_schema = vocabDatabaseSchema)

  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataVisitDetailDurationByType <- DatabaseConnector::querySql(conn, queryVisitDetailDurationByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)

  buildVisitDetailReport <- function(concept_id) {
    report <- {
    }
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID ==
      concept_id, c(3, 4, 5, 6)]
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,
      c(3, 4)]
    report$VISIT_DETAIL_DURATION_BY_TYPE <- dataVisitDetailDurationByType[dataVisitDetailDurationByType$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID ==
      concept_id, c(2, 3, 4, 5, 6, 7, 8, 9)]
    filename <- paste(outputPath, "/visitdetail/visitdetail_", concept_id, ".json", sep = "")

    write(jsonlite::toJSON(report, method = "C"), filename)

    # Update progressbar:
    env <- parent.env(environment())
    curVal <- get("progress", envir = env)
    assign("progress", curVal + 1, envir = env)
    utils::setTxtProgressBar(get("progressBar", envir = env),
                             (curVal + 1)/get("totalCount", envir = env))
  }

  dummy <- lapply(uniqueConcepts, buildVisitDetailReport)

  utils::setTxtProgressBar(progressBar, 1)
  close(progressBar)
}


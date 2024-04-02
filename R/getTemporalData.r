# @file getTemporalData
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
# @author Frank DeFalco
# @author Vojtech Huser
# @author Chris Knoll
# @author Ajit Londhe
# @author Taha Abdul-Basser
# @author Anthony Molinaro

#' @title
#' getTemporalData
#'
#' @description
#' \code{getTemporalData} Retrieve specific monthly analyses data to support temporal
#' characterization.
#'
#' @details
#' \code{getTemporalData} Assumes \code{achilles} has been run. \preformatted{Currently supported
#' Achilles monthly analyses are: 202 - Visit Occurrence 402 - Condition occurrence 602 - Procedure
#' Occurrence 702 - Drug Exposure 802 - Observation 1802 - Measurement 2102 - Device}
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema       Fully qualified name of database schema that contains OMOP CDM
#'                                schema. On SQL Server, this should specifiy both the database and the
#'                                schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema   Fully qualified name of database schema that we can write final
#'                                results to. Default is cdmDatabaseSchema. On SQL Server, this should
#'                                specifiy both the database and the schema, so for example, on SQL
#'                                Server, 'cdm_results.dbo'.
#' @param analysisIds             (OPTIONAL) A vector containing the set of Achilles analysisIds for
#'                                which results will be returned. The following are supported:
#'                                \code{202,402,602,702,802,1802,2102}. If not specified, data for all
#'                                analysis will be returned. Ignored if \code{conceptId} is given.
#' @param conceptId               (OPTIONAL) A SNOMED concept_id from the \code{CONCEPT} table for
#'                                which a monthly Achilles analysis exists. If not specified, all
#'                                concepts for a given analysis will be returned.
#' @return
#' A data frame of query results from \code{DatabaseConnector}
#'
#' @examples
#' \dontrun{
#' pneumonia <- 255848
#' monthlyResults <- getTemporalData(connectionDetails = connectionDetails,
#'                                   cdmDatabaseSchema = "cdm",
#'
#'   resultsDatabaseSchema = "results", conceptId = pneumonia)
#' }
#'
#' @export


getTemporalData <- function(connectionDetails,
                            cdmDatabaseSchema,
                            resultsDatabaseSchema,
                            analysisIds = NULL,

  conceptId = NULL) {
  if (!is.null(conceptId)) {
    print(paste0("Retrieving Achilles monthly data for temporal support for concept_id: ",
                 conceptId))
    conceptIdGiven <- TRUE
    analysisIdGiven <- FALSE
  } else if (!is.null(analysisIds)) {
    print(paste0("Retrieving Achilles monthly data for temporal support for analyses: ",
                 paste(analysisIds,
      collapse = ", ")))
    conceptIdGiven <- FALSE
    analysisIdGiven <- TRUE
  } else {
    print("Retrieving Achilles monthly data for temporal support for all supported analyses")
    conceptIdGiven <- FALSE
    analysisIdGiven <- FALSE
  }

  if (typeof(connectionDetails$server) == "character") {
    dbName <- toupper(strsplit(connectionDetails$server, "/")[[1]][2])
  } else if (typeof(connectionDetails$server()) == "character") {
    dbName <- toupper(strsplit(connectionDetails$server(), "/")[[1]][2])
  } else {
    dbName <- NA
  }

  translatedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "temporal/achilles_temporal_data.sql",
    packageName = "Achilles", dbms = connectionDetails$dbms, db_name = dbName, cdm_schema = cdmDatabaseSchema,
    results_schema = resultsDatabaseSchema, concept_id = conceptId, analysis_ids = analysisIds, concept_id_given = conceptIdGiven,
    analysis_id_given = analysisIdGiven)

  conn <- DatabaseConnector::connect(connectionDetails)

  queryResults <- DatabaseConnector::querySql(conn, translatedSql)

  on.exit(DatabaseConnector::disconnect(conn))

  return(queryResults)

}

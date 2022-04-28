# @file runMissingAnalyses
#
# Copyright 2022 Observational Health Data Sciences and Informatics
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
#' runMissingAnalyses
#'
#' @description
#' \code{runMissingAnalyses} Automatically find and compute analyses that haven't been executed.
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
#' @param scratchDatabaseSchema   Fully qualified name of the database schema that will store all of
#'                                the intermediate scratch tables, so for example, on SQL Server,
#'                                'cdm_scratch.dbo'. Must be accessible to/from the cdmDatabaseSchema
#'                                and the resultsDatabaseSchema. Default is resultsDatabaseSchema.
#'                                Making this "#" will run Achilles in single-threaded mode and use
#'                                temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema     String name of database schema that contains OMOP Vocabulary. Default
#'                                is cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#' @param tempEmulationSchema     Formerly tempEmulationSchema.  For databases like Oracle where you
#'                                must specify the name of the database schema where you want all
#'                                temporary tables to be managed. Requires create/insert permissions to
#'                                this database.
#' @param outputFolder            Path to store logs and SQL files
#' @param defaultAnalysesOnly     Boolean to determine if only default analyses should be run.
#'                                Including non-default analyses is substantially more resource
#'                                intensive.  Default = TRUE
#' @examples
#' \dontrun{
#' Achilles::runMissingAnalyses(connectionDetails = connectionDetails,
#'                              cdmDatabaseSchema = "cdm",
#'                              resultsDatabaseSchema = "results",
#'
#'   outputFolder = "/tmp")
#' }
#'
#' @export

runMissingAnalyses <- function(connectionDetails,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema = cdmDatabaseSchema,

  scratchDatabaseSchema = resultsDatabaseSchema, vocabDatabaseSchema = cdmDatabaseSchema, tempEmulationSchema = resultsDatabaseSchema,
  outputFolder = "output", defaultAnalysesOnly = TRUE) {

  # Determine which analyses are missing by comparing analysisDetails with achilles_results and
  # achilles_results_dist
  analysisDetails <- getAnalysisDetails()

  # Determine which analyses to run
  index1 <- which(analysisDetails$IS_DEFAULT == 1 & analysisDetails$COST == 1 & analysisDetails$DISTRIBUTION == 0)
  index2 <- which(analysisDetails$IS_DEFAULT == 1 & analysisDetails$COST == 1 & analysisDetails$DISTRIBUTION == 1)
  index3 <- which(analysisDetails$IS_DEFAULT == 1 & analysisDetails$COST == 0 & analysisDetails$DISTRIBUTION == 0)
  index4 <- which(analysisDetails$IS_DEFAULT == 1 & analysisDetails$COST == 0 & analysisDetails$DISTRIBUTION == 1)
  index5 <- which(analysisDetails$IS_DEFAULT == 0 & analysisDetails$COST == 1 & analysisDetails$DISTRIBUTION == 0)
  index6 <- which(analysisDetails$IS_DEFAULT == 0 & analysisDetails$COST == 1 & analysisDetails$DISTRIBUTION == 1)
  index7 <- which(analysisDetails$IS_DEFAULT == 0 & analysisDetails$COST == 0 & analysisDetails$DISTRIBUTION == 0)
  index8 <- which(analysisDetails$IS_DEFAULT == 0 & analysisDetails$COST == 0 & analysisDetails$DISTRIBUTION == 1)

  if (defaultAnalysesOnly && runCostAnalysis) {
    allResultAnalysisIds <- analysisDetails[index1, ]$ANALYSIS_ID
    allDistAnalysisIds <- analysisDetails[index2, ]$ANALYSIS_ID
  } else if (defaultAnalysesOnly && !runCostAnalysis) {
    allResultAnalysisIds <- analysisDetails[index3, ]$ANALYSIS_ID
    allDistAnalysisIds <- analysisDetails[index4, ]$ANALYSIS_ID
  } else if (!defaultAnalysesOnly && runCostAnalysis) {
    allResultAnalysisIds <- analysisDetails[index5, ]$ANALYSIS_ID
    allDistAnalysisIds <- analysisDetails[index6, ]$ANALYSIS_ID
  } else {
    allResultAnalysisIds <- analysisDetails[index7, ]$ANALYSIS_ID
    allDistAnalysisIds <- analysisDetails[index8, ]$ANALYSIS_ID
  }

  conn <- DatabaseConnector::connect(connectionDetails)

  sql <- "select distinct analysis_id from @results_schema.achilles_results;"
  sql <- SqlRender::render(sql, results_schema = resultsDatabaseSchema)
  sql <- SqlRender::translate(sql, targetDialect = connectionDetails$dbms)

  existingResultAnalysisIds <- DatabaseConnector::querySql(conn, sql)$ANALYSIS_ID

  sql <- "select distinct analysis_id from @results_schema.achilles_results_dist;"
  sql <- SqlRender::render(sql, results_schema = resultsDatabaseSchema)
  sql <- SqlRender::translate(sql, targetDialect = connectionDetails$dbms)

  existingDistAnalysisIds <- DatabaseConnector::querySql(conn, sql)$ANALYSIS_ID

  missingResultAnalysisIds <- setdiff(allResultAnalysisIds, existingResultAnalysisIds)
  missingDistAnalysisIds <- setdiff(allDistAnalysisIds, existingDistAnalysisIds)

  DatabaseConnector::disconnect(conn)

  missingAnalysisIds <- c(missingResultAnalysisIds, missingDistAnalysisIds)

  if (length(missingAnalysisIds) == 0) {
    print("NO MISSING ANALYSES FOUND")
  } else {
    # By supplying analysisIds along with specifying createTable=F and updateGivenAnalysesOnly=T,
    # we add the missing analysis_ids without removing existing data
    achilles(connectionDetails = connectionDetails,
             cdmDatabaseSchema = cdmDatabaseSchema,
             resultsDatabaseSchema = resultsDatabaseSchema,
      scratchDatabaseSchema = scratchDatabaseSchema, vocabDatabaseSchema = cdmDatabaseSchema, tempEmulationSchema = tempEmulationSchema,
      analysisIds = missingAnalysisIds, defaultAnalysesOnly = defaultAnalysesOnly,
      outputFolder = outputFolder, createTable = FALSE, updateGivenAnalysesOnly = TRUE)
  }
}

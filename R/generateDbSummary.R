# @file generateDbSummary
#
# Copyright 2021 Observational Health Data Sciences and Informatics
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


#' @title
#' generateDbSummary
#'
#' @description
#' \code{generateDbSummary} can be run after the Achilles analyses are complete 
#' to create a high-level database summary.
#'
#' @details
#' Used to generate a high-level database summary consisting of earliest date available, latest
#' date available, median age at first observation, total persons, etc. This function
#' creates a summary table meant for a manuscript detailing the network of databases
#' used in an analysis
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
#' @param country                 The country of origin of the database
#' @param provenance              The provenance of the data (EHR, claims, registry, etc)
#'
#' @return
#' none
#'
#' @examples
#' \dontrun{
#' connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "sql server",
#'                                                                 server = "yourserver")
#' dbSummary <- generateDbSummary(connectionDetails,
#'                                cdmDatabaseSchema = "cdm_schema",
#'                                resultsDatabaseSchema = "results_schema",
#'                                country = "Country of Origin",
#'                                provenance = "Provenance of data")
#' }
#' @export

generateDbSummary <- function (connectionDetails,
                               cdmDatabaseSchema,
                               resultsDatabaseSchema,
                               country,
                               provenance){
  
  conn <- DatabaseConnector::connect(connectionDetails)
  
  sql <-
    SqlRender::loadRenderTranslateSql(
      sqlFilename = "summary/generateDbSummary.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      warnOnMissingParameters = FALSE,
      cdm_database_schema = cdmDatabaseSchema,
      results_database_schema = resultsDatabaseSchema,
      country = country,
      provenance = provenance
    )
  
  dbSummary <- DatabaseConnector::querySql(conn, sql)
  
  sql <-
    SqlRender::loadRenderTranslateSql(
      sqlFilename = "summary/dbSourceVocabs.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      warnOnMissingParameters = FALSE,
      cdm_database_schema = cdmDatabaseSchema,
      results_database_schema = resultsDatabaseSchema,
      country = country,
      provenance = provenance
    )
  
  dbSourceVocabs <- DatabaseConnector::querySql(conn, sql)
  
  sql <-
    SqlRender::loadRenderTranslateSql(
      sqlFilename = "summary/dbVisitDist.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      warnOnMissingParameters = FALSE,
      cdm_database_schema = cdmDatabaseSchema,
      results_database_schema = resultsDatabaseSchema,
      country = country,
      provenance = provenance
    )
  
  dbVisitDist <- DatabaseConnector::querySql(conn, sql)
  
  DatabaseConnector::dbDisconnect(conn)

  # extract columns and pivot
  dbInfo <- dbSummary[1,c(1,2,3,4)]
  row.names(dbSummary) <- dbSummary$ATTRIBUTE_NAME
  df <- dbSummary[,c('ATTRIBUTE_VALUE')]
  df_t <- t(df)
  colnames(df_t) <- rownames(dbSummary)
  dbSummaryFinal <- cbind(dbInfo, df_t)
  
  colnames(dbSummaryFinal)[1:4] <- c("Data Source Name", "Data Source Abbreviation", "Source Country", "Data Provenance")
  
  return(list(summary=dbSummaryFinal, visitDist=dbVisitDist, sourceVocabs = dbSourceVocabs))
}
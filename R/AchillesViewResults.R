# @file AchillesViewResults
#
# Copyright 2019 Observational Health Data Sciences and Informatics
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


#' Launch the Achilles Heel Shiny app
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.

#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can fetch final results from.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema            Fully qualified name of the database schema that will store all of the intermediate scratch tables, so for example, on SQL Server, 'cdm_scratch.dbo'. 
#'                                         Must be accessible to/from the cdmDatabaseSchema and the resultsDatabaseSchema. Default is resultsDatabaseSchema. 
#'                                         Making this "#" will run Achilles in single-threaded mode and use temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param tempHeelPrefix                   (OPTIONAL, multi-threaded mode) The prefix to use for the "temporary" (but actually permanent) Heel tables. Default is "tmpheel"
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param outputFolder                     Path to store logs and SQL files
#' 
#' @details 
#' Launches a Shiny app that allows the user to explore the Achilles Heel results
#' 
#' @export
launchHeelResultsViewer <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
                                    scratchDatabaseSchema = resultsDatabaseSchema,
                                    vocabDatabaseSchema = cdmDatabaseSchema,
                                    tempAchillesPrefix = "tmpach",
                                    tempHeelPrefix = "tmpheel",
                                    numThreads = 1,
                                    outputFolder) {
  dependencies <- c("shiny",
                    "DT",
                    "shinydashboard",
                    "magrittr",
                    "tidyr")
  
  for (d in dependencies) {
    if (!requireNamespace(d, quietly = TRUE)) {
      message <- sprintf(
        "You must install %1s first. You may install it using devtools with the following code: 
        \n    install.packages('%2s')
        \n\nAlternately, you might want to install ALL suggested packages using:
        \n    devtools::install_github('OHDSI/Achilles', dependencies = TRUE)", d, d)
      stop(message, call. = FALSE)
    }
  }
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1
    scratchDatabaseSchema <- "#"
    schemaDelim <- "s_"
  } 

  issues <- fetchAchillesHeelResults(connectionDetails = connectionDetails, 
                                     resultsDatabaseSchema = resultsDatabaseSchema)
  
  Sys.setenv(outputFolder = file.path(getwd(), outputFolder),
             sourceName = .getSourceName(connectionDetails, cdmDatabaseSchema),
             dbms = connectionDetails$dbms,
             cdmDatabaseSchema = cdmDatabaseSchema,
             resultsDatabaseSchema = resultsDatabaseSchema,
             scratchDatabaseSchema = scratchDatabaseSchema,
             schemaDelim = schemaDelim,
             tempAchillesPrefix = tempAchillesPrefix,
             tempHeelPrefix = tempHeelPrefix)
  
  saveRDS(object = issues, file = file.path(outputFolder, "heelResults.rds"))
  
  appDir <- system.file("shinyApps", "heelResults", package = "Achilles")
  shiny::runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}


#' @title fetchAchillesHeelResults
#'
#' @description
#' \code{fetchAchillesHeelResults} retrieves the AchillesHeel results for the AChilles analysis to identify potential data quality issues.
#' 
#' @details
#' AchillesHeel is a part of the Achilles analysis aimed at identifying potential data quality issues. It will list errors (things
#' that should really be fixed) and warnings (things that should at least be investigated).
#'
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can fetch final results from.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' 
#' @return                                 A table listing all identified issues 
#' @examples                               \dontrun{
#'                                            connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
#'                                            achillesResults <- achilles(connectionDetails, "cdm5_sim", "scratch", "TestDB")
#'                                            fetchAchillesHeelResults(connectionDetails, "scratch")
#'                                         }
#' @export
fetchAchillesHeelResults <- function(connectionDetails, 
                                     resultsDatabaseSchema) { 
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sql <- SqlRender::render(sql = "select * from @resultsDatabaseSchema.achilles_heel_results",
                              resultsDatabaseSchema = resultsDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  issues <- DatabaseConnector::querySql(connection = connection, sql = sql)
  DatabaseConnector::disconnect(connection = connection)
  
  issues
}

#' @title fetchAchillesAnalysisResults
#'
#' @description
#' \code{fetchAchillesAnalysisResults} returns the results for one Achilles analysis Id.
#' 
#' @details
#' See \code{data(analysesDetails)} for a list of all Achilles analyses and their Ids.
#'
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can fetch final results from.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param analysisId                       A single analysisId
#' 
#' @return                                 An object of type \code{achillesAnalysisResults}
#' @examples                               \dontrun{
#'                                            connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
#'                                            achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'                                            fetchAchillesAnalysisResults(connectionDetails, "scratch",106)
#'                                         }
#' @export
fetchAchillesAnalysisResults <- function (connectionDetails, 
                                          resultsDatabaseSchema, 
                                          analysisId) {
  
  analysisDetails <- getAnalysisDetails()
  analysisDetails <- analysisDetails[analysisDetails$ANALYSIS_ID == analysisId,]
  
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection = connection))
  
  sql <- "select * from @resultsDatabaseSchema.achilles_results@dist where analysis_id = @analysisId;"
  sql <- SqlRender::render(sql = sql,
                           resultsDatabaseSchema = resultsDatabaseSchema,
                           analysisId = analysisId,
                           dist = ifelse(analysisDetails[1,]$DISTRIBUTION == 0, "", "_dist"))
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  analysisResults <- DatabaseConnector::querySql(connection = connection, sql = sql)
  
  colnames(analysisResults) <- lapply(colnames(analysisResults), function(s) {
    if (startsWith(x = s, prefix = "STRATUM")) {
      strataName <- analysisDetails[sprintf("%s_NAME", s)][[1]] 
      if (is.na(strataName) | strataName == "") {
        s
      } else {
        strataName
      }
    } else {
      s
    }
  })
  
  result <- list(analysisId = analysisId,
                 analysisName = analysisDetails[1,]$ANALYSIS_NAME,
                 analysisResults = analysisResults)
  
  class(result) <- "achillesAnalysisResults"
  result
}

# @file Achilles
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
# @author Martijn Schuemie
# @author Patrick Ryan

#' The main Achilles analysis
#'
#' @description
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#'
#' @details
#' PATRICK HOMEWORK:   complete details
#' 
#' 
#' @param connectionDetails	An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema			string name of database schema that contains OMOP CDM and vocabulary
#' @param resultsSchema		string name of database schema that we can write results to. Default is cdmSchema
#' @param sourceName		string name of the database, as recorded in results
#' @param analysisIds		(optional) a vector containing the set of Achilles analysisIds for which results will be generated.
#' If not specified, all analyses will be executed. See \code{data(analysesDetails)} for a list of all Achilles analyses and their Ids.
#' @param createTable     If true, new results tables will be created in the results schema. If not, the tables are assumed to already exists, and analysis results will be added
#' @param smallcellcount     To avoid patient identifiability, cells with small counts (<= smallcellcount) are deleted.
#' 
#' @return An object of type \code{achillesResults} containing details for connecting to the database containing the results 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   fetchAchillesAnalysisResults(connectionDetails, "scratch", 106)
#' }
#' @export
achilles <- function (connectionDetails, cdmSchema, resultsSchema, sourceName = "", analysisIds, createTable = TRUE, smallcellcount = 5){
  if (missing(analysisIds))
    analysisIds = analysesDetails$ANALYSIS_ID
  
  if (missing(resultsSchema))
    resultsSchema <- cdmSchema
  
  renderedSql <- loadRenderTranslateSql(sqlFilename = "Achilles.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    CDM_schema = cdmSchema, 
                                    results_schema = resultsSchema, 
                                    source_name = sourceName, 
                                    list_of_analysis_ids = analysisIds,
                                    createTable = createTable,
                                    smallcellcount = smallcellcount
  )
  
  conn <- connect(connectionDetails)
  
  writeLines("Executing multiple queries. This could take a while")
  executeSql(conn,connectionDetails$dbms,renderedSql)
  writeLines(paste("Done. Results can now be found in",resultsSchema))
  
  dummy <- dbDisconnect(conn)
  
  resultsConnectionDetails <- connectionDetails
  resultsConnectionDetails$schema = resultsSchema
  result <- list(resultsConnectionDetails = resultsConnectionDetails, 
                 resultsTable = "ACHILLES_results",
                 resultsDistributionTable ="ACHILLES_results_dist",
                 analysis_table = "ACHILLES_analysis",
                 sourceName = sourceName,
                 analysisIds = analysisIds,
                 sql = renderedSql,
                 call = match.call())
  class(result) <- "achillesResults"
  result
}
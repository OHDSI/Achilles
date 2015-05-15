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
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmDatabaseSchema    	string name of database schema that contains OMOP CDM and vocabulary. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.
#' @param oracleTempSchema    For Oracle only: the name of the database schema where you want all temporary tables to be managed. Requires create/insert permissions to this database. 
#' @param resultsDatabaseSchema		string name of database schema that we can write results to. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param sourceName		string name of the database, as recorded in results
#' @param analysisIds		(optional) a vector containing the set of Achilles analysisIds for which results will be generated.
#' If not specified, all analyses will be executed. See \code{data(analysesDetails)} for a list of all Achilles analyses and their Ids.
#' @param createTable     If true, new results tables will be created in the results schema. If not, the tables are assumed to already exists, and analysis results will be added
#' @param smallcellcount     To avoid patient identifiability, cells with small counts (<= smallcellcount) are deleted.
#' @param cdmVersion     Define the OMOP CDM version used:  currently support "4" and "5".  Default = "4"
#' @param runHeel     Boolean to determine if Achilles Heel data quality reporting will be produced based on the summary statistics.  Default = TRUE
#' @param validateSchema     Boolean to determine if CDM Schema Validation should be run. This could be very slow.  Default = TRUE
#' 
#' @return An object of type \code{achillesResults} containing details for connecting to the database containing the results 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   fetchAchillesAnalysisResults(connectionDetails, "scratch", 106)
#' }
#' @export
achilles <- function (connectionDetails, 
                      cdmDatabaseSchema, 
                      oracleTempSchema = cdmDatabaseSchema,
                      resultsDatabaseSchema = cdmDatabaseSchema, 
                      sourceName = "", 
                      analysisIds, 
                      createTable = TRUE, 
                      smallcellcount = 5, 
                      cdmVersion = "4", 
                      runHeel = TRUE,
                      validateSchema = TRUE){
  
  if (cdmVersion == "4")  {
    achillesFile <- "Achilles_v4.sql"
    heelFile <- "AchillesHeel_v4.sql"
  } else if (cdmVersion == "5") {
    achillesFile <- "Achilles_v5.sql"
    heelFile <- "AchillesHeel_v5.sql"
  } else  {
    stop("Error: Invalid CDM Version number, use 4 or 5")
  }
  
  if (missing(analysisIds))
    analysisIds = analysesDetails$ANALYSIS_ID
  
  cdmDatabase <- strsplit(cdmDatabaseSchema ,"\\.")[[1]][1]
  resultsDatabase <- strsplit(resultsDatabaseSchema ,"\\.")[[1]][1]
  
  achillesSql <- loadRenderTranslateSql(sqlFilename = achillesFile,
                                        packageName = "Achilles",
                                        dbms = connectionDetails$dbms,
                                        oracleTempSchema = oracleTempSchema,
                                        cdm_database = cdmDatabase,
                                        cdm_database_schema = cdmDatabaseSchema,
                                        results_database = resultsDatabase, 
                                        results_database_schema = resultsDatabaseSchema,
                                        source_name = sourceName, 
                                        list_of_analysis_ids = analysisIds,
                                        createTable = createTable,
                                        smallcellcount = smallcellcount,
                                        validateSchema = validateSchema
  )
  
  conn <- connect(connectionDetails)
  
  writeLines("Executing multiple queries. This could take a while")
  executeSql(conn,achillesSql)
  writeLines(paste("Done. Achilles results can now be found in",resultsDatabase))
  
  if (runHeel) {
    heelSql <- loadRenderTranslateSql(sqlFilename = heelFile,
                                      packageName = "Achilles",
                                      dbms = connectionDetails$dbms,
                                      oracleTempSchema = oracleTempSchema,
                                      cdm_database_schema = cdmDatabaseSchema,
                                      results_database = resultsDatabase,
                                      results_database_schema = resultsDatabaseSchema,
                                      source_name = sourceName, 
                                      list_of_analysis_ids = analysisIds,
                                      createTable = createTable,
                                      smallcellcount = smallcellcount
    )
    
    writeLines("Executing Achilles Heel. This could take a while")
    executeSql(conn,heelSql)
    writeLines(paste("Done. Achilles Heel results can now be found in",resultsDatabase))    
    
  }
  
  dummy <- dbDisconnect(conn)
  
  resultsConnectionDetails <- connectionDetails
  resultsConnectionDetails$schema = resultsDatabaseSchema
  result <- list(resultsConnectionDetails = resultsConnectionDetails, 
                 resultsTable = "ACHILLES_results",
                 resultsDistributionTable ="ACHILLES_results_dist",
                 analysis_table = "ACHILLES_analysis",
                 sourceName = sourceName,
                 analysisIds = analysisIds,
                 AchillesSql = achillesSql,
                 HeelSql = heelSql,
                 call = match.call())
  class(result) <- "achillesResults"
  result
}

#' @export
achillesHeel <- function (connectionDetails, 
                      cdmDatabaseSchema, 
                      oracleTempSchema = cdmDatabaseSchema,
                      resultsDatabaseSchema = cdmDatabaseSchema,
                      cdmVersion = "4"){
  
  resultsDatabase <- strsplit(resultsDatabaseSchema ,"\\.")[[1]][1]
  
  if (cdmVersion == "4")  {
    heelFile <- "AchillesHeel_v4.sql"
  } else if (cdmVersion == "5") {
    heelFile <- "AchillesHeel_v5.sql"
  } else  {
    stop("Error: Invalid CDM Version number, use 4 or 5")
  }
  
  heelSql <- loadRenderTranslateSql(sqlFilename = heelFile,
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    oracleTempSchema = oracleTempSchema,
                                    cdm_database_schema = cdmDatabaseSchema,
                                    results_database = resultsDatabase,
                                    results_database_schema = resultsDatabaseSchema
  );
  
  conn <- connect(connectionDetails);
  writeLines("Executing Achilles Heel. This could take a while");
  executeSql(conn,heelSql);
  dummy <- dbDisconnect(conn);
  writeLines(paste("Done. Achilles Heel results can now be found in",resultsDatabase))
}

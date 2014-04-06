# @file OSCAR.R
#
# Copyright 2014 Observational Health Data Sciences and Informatics
#
# This file is part of OSCAR
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

#' @title oscar
#'
#' @description
#' \code{oscar} creates descriptive statistics summary for an entire OMOP CDM instance.
#'
#' @details
#' PATRICK HOMEWORK:   complete details
#' 
#' 
#' @param connectionDetails	An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmSchema			string name of databsae schema that contains OMOP CDM and vocabulary
#' @param resultsSchema		string name of database schema that we can write results to
#' @param sourceName		string name of the database, as recorded in results
#' @param analysisIds		(optional) a vector containing the set of OSCAR analysisIds for which results will be generated.
#' If not specified, all analyses will be executed.
#' 
#' @return An object of type \code{oscarResults} containing details for connecting to the database containing the results 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   oscarResults <- oscar(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   plot(oscarResults, "population")
#' }
#' @export
oscar <- function (connectionDetails, cdmSchema, resultsSchema, sourceName, analysisIds){
	if (missing(analysisIds))
		analysisIds = c() #Todo: add ids
	
	pathToSql <- system.file("sql", "OSCARparameterizedSQL.txt", package="OSCAR")
	parameterizedSql <- readChar(pathToSql,file.info(pathToSql)$size)

	renderedSql <- renderSql(parameterizedSql[1], CDM_schema = cdmSchema, results_schema = resultsSchema, source_name = sourceName)$sql
	

	conn <- connectUsingConnectionDetails(connectionDetails)
	
	writeLines("Executing large query. This could take a while")
	dbSendUpdate(conn,renderedSql)
	writeLines(paste("Done. Results can now be found in",resultsSchema))
	
	dbDisconnect(conn)
	
	resultsConnectionDetails <- connectionDetails
	resultsConnectionDetails$schema = resultsSchema
	
	result <- list(resultsConnectionDetails = resultsConnectionDetails, call = match.call())
	class(result) <- "oscarResults"
	result
}
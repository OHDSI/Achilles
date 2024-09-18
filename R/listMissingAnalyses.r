# @file listMissingAnalyses
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
#' listMissingAnalyses
#'
#' @description
#' \code{listMissingAnalyses} Find and return analyses that exist in \code{getAnalysisDetails}, but
#' not in achilles_results or achilles_results_dist
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema   Fully qualified name of database schema that contains
#'                                achilles_results and achilles_results_dist tables.
#'
#' @return
#' A dataframe which is a subset of \code{getAnalysisDetails}
#'
#' @examples
#' \dontrun{
#' Achilles::listMissingAnalyses(connectionDetails = connectionDetails,
#'                               resultsDatabaseSchema = "results")
#' }
#'
#' @export

listMissingAnalyses <- function(connectionDetails, resultsDatabaseSchema) {

  # Determine which analyses are missing by comparing analysisDetails with achilles_results and
  # achilles_results_dist
  analysisDetails <- getAnalysisDetails()
  allAnalysisIds <- analysisDetails$analysis_id

  conn <- DatabaseConnector::connect(connectionDetails)
  print("Retrieving previously computed achilles_results and achilles_results_dist data...")

  sql <- "select distinct analysis_id from @results_schema.achilles_results
          union
         select distinct analysis_id from @results_schema.achilles_results_dist;"

  sql <- SqlRender::render(sql, results_schema = resultsDatabaseSchema)
  sql <- SqlRender::translate(sql, targetDialect = connectionDetails$dbms)

  existingAnalysisIds <- DatabaseConnector::querySql(conn, sql)$analysis_id

  DatabaseConnector::disconnect(conn)

  missingAnalysisIds <- setdiff(allAnalysisIds, existingAnalysisIds)

  colsToDisplay <- c("analysis_id","distribution","category","is_default","analysis_name")
  retVal <- analysisDetails[analysisDetails$analysis_id %in% missingAnalysisIds, colsToDisplay]
  retVal <- retVal[order(retVal$analysis_id), ]

  return(retVal)
}

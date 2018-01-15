#' @title fetchAchillesHeelResults
#'
#' @description
#' \code{fetchAchillesHeelResults} retrieves the AchillesHeel results for the AChilles analysis to identify potential data quality issues.
#' 
#' @details
#' AchillesHeel is a part of the Achilles analysis aimed at identifying potential data quality issues. It will list errors (things
#' that should really be fixed) and warnings (things that should at least be investigated).
#'
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param resultsDatabase		Name of database containing the Achilles descriptive statistics. 
#' 
#' @return A table listing all identified issues 
#' @examples \dontrun{
#'   connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   fetchAchillesHeelResults(connectionDetails, "scratch")
#' }
#' @export
fetchAchillesHeelResults <- function (connectionDetails, resultsDatabase){
  connectionDetails$schema = resultsDatabase
  conn <- DatabaseConnector::connect(connectionDetails)
  
  sql <- "SELECT * FROM ACHILLES_HEEL_results"
  issues <- DatabaseConnector::querySql(conn,sql)
  
  DatabaseConnector::disconnect(conn)
  
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
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param resultsDatabase  	Name of database containing the Achilles descriptive statistics. 
#' @param analysisId   A single analysisId
#' 
#' @return An object of type \code{achillesAnalysisResults}
#' @examples \dontrun{
#'   connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   fetchAchillesAnalysisResults(connectionDetails, "scratch",106)
#' }
#' @export
fetchAchillesAnalysisResults <- function (connectionDetails, resultsDatabase, analysisId){
  connectionDetails$schema = resultsDatabase
  conn <- DatabaseConnector::connect(connectionDetails)
  
  sql <- "SELECT * FROM ACHILLES_analysis WHERE analysis_id = @analysisId"
  sql <- SqlRender::renderSql(sql,analysisId = analysisId)$sql
  analysisDetails <- DatabaseConnector::querySql(conn,sql)
  
  sql <- "SELECT * FROM ACHILLES_results WHERE analysis_id = @analysisId"
  sql <- SqlRender::renderSql(sql,analysisId = analysisId)$sql
  analysisResults <- DatabaseConnector::querySql(conn,sql)
  
  if (nrow(analysisResults) == 0){
    sql <- "SELECT * FROM ACHILLES_results_dist WHERE analysis_id = @analysisId"
    sql <- SqlRender::renderSql(sql,analysisId = analysisId)$sql
    analysisResults <- DatabaseConnector::querySql(conn,sql)
  }
  
  colnames(analysisDetails) <- toupper(colnames(analysisDetails))
  colnames(analysisResults) <- toupper(colnames(analysisResults))
  
  for (i in 1:5){
    stratumName <- analysisDetails[,paste("STRATUM",i,"NAME",sep="_")]
    if (is.na(stratumName)){
      analysisResults[,paste("STRATUM",i,sep="_")] <- NULL
    } else {
      colnames(analysisResults)[colnames(analysisResults) == paste("STRATUM",i,sep="_")] <- toupper(stratumName)
    }
  }
  
  DatabaseConnector::disconnect(conn)
  
  result <- list(analysisId = analysisId,
                 analysisName = analysisDetails$ANALYSIS_NAME,
                 analysisResults = analysisResults)
  class(result) <- "achillesAnalysisResults"
  result
}

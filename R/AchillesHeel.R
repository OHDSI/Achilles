#' @title achillesHeel
#'
#' @description
#' \code{achillesHeel} uses the Achilles descriptive statistics to identify potential data quality issues.
#'
#' @details
#' PATRICK HOMEWORK:   complete details
#' 
#' 
#' @param connectionDetails  An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param resultsSchema		string name of database schema containing the Achilles descriptive statistics. Default is cdmSchema
#' 
#' @return An object of type \code{achillesHeelResults} containing the list of any data quality issues. 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   achillesHeelResults <- achillesHeel(connectionDetails, "scratch")
#'   summary(achillesHeelResults)
#' }
#' @export
achillesHeel <- function (connectionDetails, resultsSchema){
  connectionDetails$schema = resultsSchema
  conn <- connect(connectionDetails)
  
  sql <- "SELECT * FROM ACHILLES_HEEL_results"
  issues <- dbGetQuery(conn,sql)
  
  resultsConnectionDetails <- connectionDetails
  resultsConnectionDetails$schema = resultsSchema
  result <- list(issues = issues,
                 resultsConnectionDetails = resultsConnectionDetails, 
                 resultsTable = "ACHILLES_HEEL_results",
                 call = match.call())
  class(result) <- "achillesHeelResults"
  
  dummy <- dbDisconnect(conn)
  
  result
}

#' @export
summary.achillesHeelResults <- function(achillesHeelResults) {
  achillesHeelResults$issues
}
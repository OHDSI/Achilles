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
#' @param cdmSchema			string name of database schema that contains OMOP CDM and vocabulary
#' @param resultsSchema		string name of database schema containing the Achilles descriptive statistics. Default is cdmSchema
#' 
#' @return An object of type \code{achillesHeelResults} containing the list of any data quality issues. 
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
#'   achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
#'   achillesHeelResults <- achillesHeel(connectionDetails, "cdm4_sim", "scratch")
#'   summary(achillesHeelResults)
#' }
#' @export
achillesHeel <- function (connectionDetails, cdmSchema, resultsSchema){
  if (missing(resultsSchema))
    resultsSchema <- cdmSchema
  
  renderedSql <- renderAndTranslate(sqlFilename = "AchillesHeel.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    cdmSchema = cdmSchema
  )
  
  connectionDetails$schema = resultsSchema
  conn <- connect(connectionDetails)
  
  writeLines("Executing multiple queries. This could take a while")
  executeSql(conn,connectionDetails$dbms,renderedSql)
  writeLines(paste("Done. Results can now be found in",resultsSchema))
  
  sql <- "SELECT * FROM ACHILLES_HEEL_results"
  issues <- dbGetQuery(conn,sql)
  
  resultsConnectionDetails <- connectionDetails
  resultsConnectionDetails$schema = resultsSchema
  result <- list(issues = issues,
                 resultsConnectionDetails = resultsConnectionDetails, 
                 resultsTable = "ACHILLES_HEEL_results",
                 sql = renderedSql,
                 call = match.call())
  class(result) <- "achillesHeelResults"
  
  dummy <- dbDisconnect(conn)
  
  result
}

#' @export
summary.achillesHeelResults <- function(achillesHeelResults) {
  achillesHeelResults$issues
}
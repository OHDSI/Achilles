
#' Launch the Achilles Heel Shiny app
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.

#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can fetch final results from.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param outputFolder                     Path to store logs and SQL files
#' 
#' @details 
#' Launches a Shiny app that allows the user to explore the Achilles Heel results
#' 
#' @export
launchHeelResultsViewer <- function(connectionDetails,
                                    cdmDatabaseSchema,
                                    resultsDatabaseSchema,
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

  
  issues <- fetchAchillesHeelResults(connectionDetails = connectionDetails, 
                                     resultsDatabaseSchema = resultsDatabaseSchema)
  
  Sys.setenv(outputFolder = file.path(getwd(), outputFolder))
  Sys.setenv(sourceName = .getSourceName(connectionDetails, cdmDatabaseSchema))
  
  saveRDS(object = issues, file = file.path(outputFolder, "heelResults.rds"))
  
  appDir <- system.file("shinyApps", package = "Achilles")
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
fetchAchillesHeelResults <- function (connectionDetails, 
                                      resultsDatabaseSchema) { 
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sql <- SqlRender::renderSql(sql = "SELECT * FROM @resultsDatabaseSchema.achilles_heel_results",
                              resultsDatabaseSchema = resultsDatabaseSchema)$sql
  
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
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  
  if (analysisDetails$DISTRIBUTION[analysisDetails$ANALYSIS_ID == analysisId] == 0) {
    sql <- "select * from @resultsDatabaseSchema.achilles_results where analysis_id = @analysisId"
    sql <- SqlRender::renderSql(sql = sql,
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                analysisId = analysisId)$sql
    analysisResults <- DatabaseConnector::querySql(connection = connection, sql = sql)
  } else {
    sql <- "select * from @resultsDatabaseSchema.achilles_results_dist where analysis_id = @analysisId"
    sql <- SqlRender::renderSql(sql = sql,
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                analysisId = analysisId)$sql
    analysisResults <- DatabaseConnector::querySql(connection = connection, sql = sql)
  }
  
  DatabaseConnector::disconnect(connection = connection)
  
  result <- list(analysisId = analysisId,
                 analysisName = analysisDetails$ANALYSIS_NAME[analysisDetails$ANALYSIS_ID == analysisId],
                 analysisResults = analysisResults)
  
  class(result) <- "achillesAnalysisResults"
  result
}

#' @title
#' exportResultsToCSV
#'
#' @description
#' \code{exportResultsToCSV} exports all results to a CSV file
#'
#' @details
#' \code{exportResultsToCSV} writes a CSV file with all results to the export folder.
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema   Fully qualified name of database schema that we can write final
#'                                results to. Default is cdmDatabaseSchema. On SQL Server, this should
#'                                specifiy both the database and the schema, so for example, on SQL
#'                                Server, 'cdm_results.dbo'.
#' @param analysisIds             (OPTIONAL) A vector containing the set of Achilles analysisIds for
#'                                which results will be generated. If not specified, all analyses will
#'                                be executed. Use \code{\link{getAnalysisDetails}} to get a list of
#'                                all Achilles analyses and their Ids.
#' @param minCellCount            To avoid patient identification, cells with small counts (<=
#'                                minCellCount) are deleted. Set to 0 for complete summary without
#'                                small cell count restrictions.
#' @param exportFolder            Path to store results

#' @export
exportResultsToCSV <- function(connectionDetails,
                               resultsDatabaseSchema,
                               analysisIds = c(),
                               minCellCount = 5,

  exportFolder) {
  # Ensure the export folder exists
  if (!file.exists(exportFolder)) {
    dir.create(exportFolder, recursive = TRUE)
  }

  # Connect to the database
  connection <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  # Obtain the data from the achilles tables
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/raw/export_raw_achilles_results.sql",
    packageName = "Achilles", dbms = connectionDetails$dbms, warnOnMissingParameters = FALSE, results_database_schema = resultsDatabaseSchema,
    min_cell_count = minCellCount, analysis_ids = analysisIds)
  ParallelLogger::logInfo("Querying achilles_results")
  results <- DatabaseConnector::querySql(connection = connection, sql = sql)

  # Save the data to the export folder
  readr::write_csv(results, file.path(exportFolder, "achilles_results.csv"))
}


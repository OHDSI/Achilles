# @file Achilles
#
# Copyright 2022 Observational Health Data Sciences and Informatics
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


#' @title
#' achilles
#'
#' @description
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#'
#' @details
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#'
#' @param connectionDetails         An R object of type \code{connectionDetails} created using the
#'                                  function \code{createConnectionDetails} in the
#'                                  \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema         Fully qualified name of database schema that contains OMOP CDM
#'                                  schema. On SQL Server, this should specifiy both the database and
#'                                  the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema     Fully qualified name of database schema that we can write final
#'                                  results to. Default is cdmDatabaseSchema. On SQL Server, this
#'                                  should specifiy both the database and the schema, so for example,
#'                                  on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema     Fully qualified name of the database schema that will store all of
#'                                  the intermediate scratch tables, so for example, on SQL Server,
#'                                  'cdm_scratch.dbo'. Must be accessible to/from the cdmDatabaseSchema
#'                                  and the resultsDatabaseSchema. Default is resultsDatabaseSchema.
#'                                  Making this "#" will run Achilles in single-threaded mode and use
#'                                  temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema       String name of database schema that contains OMOP Vocabulary.
#'                                  Default is cdmDatabaseSchema. On SQL Server, this should specifiy
#'                                  both the database and the schema, so for example 'results.dbo'.
#' @param tempEmulationSchema       Formerly oracleTempSchema.  For databases like Oracle where you
#'                                  must specify the name of the database schema where you want all
#'                                  temporary tables to be managed. Requires create/insert permissions
#'                                  to this database.
#' @param sourceName                String name of the data source name. If blank, CDM_SOURCE table
#'                                  will be queried to try to obtain this.
#' @param analysisIds               (OPTIONAL) A vector containing the set of Achilles analysisIds for
#'                                  which results will be generated. If not specified, all analyses
#'                                  will be executed. Use \code{\link{getAnalysisDetails}} to get a
#'                                  list of all Achilles analyses and their Ids.
#' @param createTable               If true, new results tables will be created in the results schema.
#'                                  If not, the tables are assumed to already exist, and analysis
#'                                  results will be inserted (slower on MPP).
#' @param smallCellCount            To avoid patient identification, cells with small counts (<=
#'                                  smallCellCount) are deleted. Set to 0 for complete summary without
#'                                  small cell count restrictions.
#' @param cdmVersion                Define the OMOP CDM version used: currently supports v5 and above.
#'                                  Use major release number or minor number only (e.g. 5, 5.3)
#' @param createIndices             Boolean to determine if indices should be created on the resulting
#'                                  Achilles tables. Default= TRUE
#' @param numThreads                (OPTIONAL, multi-threaded mode) The number of threads to use to run
#'                                  Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix        (OPTIONAL, multi-threaded mode) The prefix to use for the scratch
#'                                  Achilles analyses tables. Default is "tmpach"
#' @param dropScratchTables         (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may
#'                                  take time depending on dbms), FALSE = leave them in place for later
#'                                  removal.
#' @param sqlOnly                   Boolean to determine if Achilles should be fully executed. TRUE =
#'                                  just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder              Path to store logs and SQL files
#' @param verboseMode               Boolean to determine if the console will show all execution steps.
#'                                  Default = TRUE
#' @param optimizeAtlasCache        Boolean to determine if the atlas cache has to be optimized.
#'                                  Default = FALSE
#' @param defaultAnalysesOnly       Boolean to determine if only default analyses should be run.
#'                                  Including non-default analyses is substantially more resource
#'                                  intensive.  Default = TRUE
#' @param updateGivenAnalysesOnly   Boolean to determine whether to preserve the results of the
#'                                  analyses NOT specified with the \code{analysisIds} parameter.  To
#'                                  update only analyses specified by \code{analysisIds}, set
#'                                  createTable = FALSE and updateGivenAnalysesOnly = TRUE. By default,
#'                                  updateGivenAnalysesOnly = FALSE, to preserve the original behavior
#'                                  of Achilles when supplied \code{analysisIds}.
#' @param excludeAnalysisIds        (OPTIONAL) A vector containing the set of Achilles analyses to
#'                                  exclude.
#' @param sqlDialect                (OPTIONAL) String to be used when specifying sqlOnly = TRUE and 
#'                                  NOT supplying the \code{connectionDetails} parameter. 
#'                                  if the \code{connectionDetails} parameter is supplied, \code{sqlDialect} 
#'                                  is ignored.  If the \code{connectionDetails} parameter is not supplied, 
#'                                  \code{sqlDialect} must be supplied to enable \code{SqlRender} 
#'                                  to translate properly.  \code{sqlDialect} takes the value normally 
#'                                  supplied to connectionDetails$dbms.  Default = NULL.
#'
#' @return
#' An object of type \code{achillesResults} containing details for connecting to the database
#' containing the results
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "sql server", server = "some_server")
#' achillesResults <- achilles(connectionDetails = connectionDetails,
#'   cdmDatabaseSchema = "cdm",
#'   resultsDatabaseSchema = "results",
#'   scratchDatabaseSchema = "scratch", 
#'   sourceName = "Some Source", 
#'   cdmVersion = "5.3", 
#'   numThreads = 10, 
#'   outputFolder = "output")
#' }
#'
#' @export
achilles <- function(connectionDetails,
                     cdmDatabaseSchema,
                     resultsDatabaseSchema = cdmDatabaseSchema,

  scratchDatabaseSchema = resultsDatabaseSchema, vocabDatabaseSchema = cdmDatabaseSchema, tempEmulationSchema = resultsDatabaseSchema,
  sourceName = "", analysisIds, createTable = TRUE, smallCellCount = 5, cdmVersion = "5", 
  createIndices = TRUE, numThreads = 1, tempAchillesPrefix = "tmpach", dropScratchTables = TRUE, sqlOnly = FALSE,
  outputFolder = "output", verboseMode = TRUE, optimizeAtlasCache = FALSE, defaultAnalysesOnly = TRUE,
  updateGivenAnalysesOnly = FALSE, excludeAnalysisIds, sqlDialect = NULL) {
  totalStart <- Sys.time()
  achillesSql <- c()

  # Check if the correct parameters are supplied when running in sqlOnly mode
  if (sqlOnly && missing(connectionDetails) && is.null(sqlDialect)) {
	stop("Error: When specifying sqlOnly = TRUE, sqlDialect or connectionDetails must be supplied.")
  }  
  if (sqlOnly && !missing(connectionDetails)) {
	print("Running Achilles in SQL ONLY mode.  Using connectionDetails, sqlDialect is ignored.  Please wait for script generation.")
  }
  if (sqlOnly && missing(connectionDetails) && !is.null(sqlDialect)) {
	connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = sqlDialect)
	print("Running Achilles in SQL ONLY mode.  Using dialect supplied by sqlDialect.  Please wait for script generation.")
  }

  
  # Log execution
  # -----------------------------------------------------------------------------------------------------------------
  ParallelLogger::clearLoggers()
  unlink(file.path(outputFolder, "log_achilles.txt"))

  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(layout = ParallelLogger::layoutTimestamp),
      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
                                         fileName = file.path(outputFolder,
        "log_achilles.txt")))
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_achilles.txt")))
  }

  logger <- ParallelLogger::createLogger(name = "achilles",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger)

  # Try to get CDM Version if not provided
  # ----------------------------------------------------------------------------------------

  if (missing(cdmVersion) && !sqlOnly) {
    cdmVersion <- .getCdmVersion(connectionDetails, cdmDatabaseSchema)
  }

  cdmVersion <- as.character(cdmVersion)

  # Check CDM version is valid
  # ---------------------------------------------------------------------------------------------------

  if (compareVersion(a = as.character(cdmVersion), b = "5") < 0) {
    stop("Error: Invalid CDM Version number; this function is only for v5 and above.
     See Achilles Git Repo to find v4 compatible version of Achilles.")
  }

  # Establish folder paths
  # --------------------------------------------------------------------------------------------------------

  if (!dir.exists(outputFolder)) {
    dir.create(path = outputFolder, recursive = TRUE)
  }

  # Get source name if none provided
  # ----------------------------------------------------------------------------------------------

  if (missing(sourceName) & !sqlOnly) {
    .getSourceName(connectionDetails, cdmDatabaseSchema)
  }

  # Obtain analyses to run
  # --------------------------------------------------------------------------------------------------------

  analysisDetails <- getAnalysisDetails()
  
  if (!missing(analysisIds)) {
    # If specific analysis_ids are given, run only those
    analysisDetails <- analysisDetails[analysisDetails$ANALYSIS_ID %in% analysisIds, ]
  } else if (defaultAnalysesOnly) {
    # If specific analyses are not given, determine whether or not to run only default analyses
    analysisDetails <- analysisDetails[analysisDetails$IS_DEFAULT == 1, ]
  }

  # Remove unwanted analyses that have not already been excluded, if any are specified
  if (!missing(excludeAnalysisIds) && any(analysisDetails$ANALYSIS_ID %in% excludeAnalysisIds)) {
    analysisDetails <- analysisDetails[-which(analysisDetails$ANALYSIS_ID %in% excludeAnalysisIds),]
  }

  resultsTables <- list(list(detailType = "results",
                             tablePrefix = tempAchillesPrefix,
                             schema = read.csv(file = system.file("csv",
    "schemas", "schema_achilles_results.csv", package = "Achilles"), header = TRUE), analysisIds = analysisDetails[analysisDetails$DISTRIBUTION <=
    0, ]$ANALYSIS_ID), list(detailType = "results_dist",
                            tablePrefix = sprintf("%1s_%2s", tempAchillesPrefix,
    "dist"), schema = read.csv(file = system.file("csv", "schemas", "schema_achilles_results_dist.csv",
    package = "Achilles"), header = TRUE), analysisIds = analysisDetails[abs(analysisDetails$DISTRIBUTION) ==
    1, ]$ANALYSIS_ID))

  # Initialize thread and scratchDatabaseSchema settings and verify ParallelLogger installed
  # ---------------------------

  schemaDelim <- "."

  # Do not connect to a database if running in sqlOnly mode
  if (sqlOnly) {
	if (.supportsTempTables(connectionDetails) && connectionDetails$dbms != "oracle") {
		scratchDatabaseSchema <- "#"
		schemaDelim <- "s_"
    }
  } else { 
  
	  if (numThreads == 1 || scratchDatabaseSchema == "#") {
		numThreads <- 1

		if (.supportsTempTables(connectionDetails) && connectionDetails$dbms != "oracle") {
		  scratchDatabaseSchema <- "#"
		  schemaDelim <- "s_"
		}

		ParallelLogger::logInfo("Beginning single-threaded execution")

		# first invocation of the connection, to persist throughout to maintain temp tables
		connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
	  } else if (!requireNamespace("ParallelLogger", quietly = TRUE)) {
		stop("Multi-threading support requires package 'ParallelLogger'.",
			 " Consider running single-threaded by setting",

		  " `numThreads = 1` and `scratchDatabaseSchema = '#'`.", " You may install it using devtools with the following code:",
		  "\n    devtools::install_github('OHDSI/ParallelLogger')", "\n\nAlternately, you might want to install ALL suggested packages using:",
		  "\n    devtools::install_github('OHDSI/Achilles', dependencies = TRUE)", call. = FALSE)
	  } else {
		ParallelLogger::logInfo("Beginning multi-threaded execution")
	  }
  }
  
  # Determine whether or not to create Achilles support tables
  # -----------------------------------------------------

  if (!createTable && missing(analysisIds)) {
    createTable <- TRUE
    preserveResults <- FALSE
  } else if (!createTable && !missing(analysisIds) && !updateGivenAnalysesOnly) {
    createTable <- TRUE
    preserveResults <- FALSE
  } else if (!createTable && !missing(analysisIds) && updateGivenAnalysesOnly) {
    preserveResults <- TRUE
  }

  ## If not creating support tables, then either remove ALL prior results or only those results for
  ## the given analysisIds ----------------------------------------------------------------

  if (!sqlOnly) {
	  if (!createTable && !preserveResults) {
		.deleteExistingResults(connectionDetails = connectionDetails,
							   resultsDatabaseSchema = resultsDatabaseSchema,

		  analysisDetails = analysisDetails)
	  } else if (!createTable && preserveResults) {
		.deleteGivenAnalyses(connectionDetails = connectionDetails,
							 resultsDatabaseSchema = resultsDatabaseSchema,

		  analysisIds = analysisIds)
	  }
  }
  
  ###### Create and populate the achilles_analysis table (assumes inst/csv/achilles_analysis_details.csv exists) 

  if (createTable) {
  
    sql <- SqlRender::loadRenderTranslateSql(
		sqlFilename = "analyses/achilles_analysis_ddl.sql",
		packageName = "Achilles", 
		dbms        = connectionDetails$dbms, 
        resultsDatabaseSchema   = resultsDatabaseSchema)

	# Populate achilles_analysis without the "distribution" and "distributed_field"
	# columns from achilles_analysis_details.csv

	analysisDetailsCsv <- Achilles::getAnalysisDetails()
	analysisDetailsCsv <- analysisDetailsCsv[,-c(2,3)]

    if (!sqlOnly) {
	  if (numThreads != 1) {
        connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
	  }
	  
	  # Create empty achilles_analysis
      DatabaseConnector::executeSql(
		connection = connection,
        sql = sql,
        errorReportFile = file.path(getwd(),"achillesErrorCreateAchillesAnalysis.txt"))
		
	  # Populate achilles_analysis with data from achilles_analysis_details.csv from above 
	  DatabaseConnector::insertTable(
		connection        = connection,
        databaseSchema    = resultsDatabaseSchema,
        tableName         = "ACHILLES_ANALYSIS",
        data              = analysisDetailsCsv,
		dropTableIfExists = FALSE,
		createTable       = FALSE,
		tempTable         = FALSE)
		
	  if (numThreads != 1) {
        DatabaseConnector::disconnect(connection)
	  }
    }
  }

  # Clean up existing scratch tables -----------------------------------------------

  if ((numThreads > 1 || !.supportsTempTables(connectionDetails)) && !sqlOnly) {
    # Drop the scratch tables
    ParallelLogger::logInfo(sprintf("Dropping scratch Achilles tables from schema %s",
                                    scratchDatabaseSchema))

    dropAllScratchTables(connectionDetails = connectionDetails,
                         scratchDatabaseSchema = scratchDatabaseSchema,

      tempAchillesPrefix = tempAchillesPrefix, numThreads = numThreads, tableTypes = c("achilles"),
      outputFolder = outputFolder, defaultAnalysesOnly = defaultAnalysesOnly)

    ParallelLogger::logInfo(sprintf("Temporary Achilles tables removed from schema %s",
                                    scratchDatabaseSchema))
  }

  # Generate Main Analyses
  # ----------------------------------------------------------------------------------------------------------------

  mainAnalysisIds <- analysisDetails$ANALYSIS_ID
  
  mainSqls <- lapply(mainAnalysisIds, function(analysisId) {
    list(analysisId = analysisId,
         sql = .getAnalysisSql(analysisId = analysisId, connectionDetails = connectionDetails,
      schemaDelim = schemaDelim, scratchDatabaseSchema = scratchDatabaseSchema, cdmDatabaseSchema = cdmDatabaseSchema,
      resultsDatabaseSchema = resultsDatabaseSchema, tempEmulationSchema = tempEmulationSchema,
      cdmVersion = cdmVersion, tempAchillesPrefix = tempAchillesPrefix, resultsTables = resultsTables,
      sourceName = sourceName, numThreads = numThreads, outputFolder = outputFolder))
  })

  achillesSql <- c(achillesSql, lapply(mainSqls, function(s) s$sql))

  if (!sqlOnly) {
    ParallelLogger::logInfo("Executing multiple queries. This could take a while")

    if (numThreads == 1) {
      for (mainSql in mainSqls) {
        start <- Sys.time()
        ParallelLogger::logInfo(sprintf("Analysis %d (%s) -- START",
                                        mainSql$analysisId,
                                        analysisDetails$ANALYSIS_NAME[analysisDetails$ANALYSIS_ID ==
          mainSql$analysisId]))
        tryCatch({
          DatabaseConnector::executeSql(connection = connection,
                                        sql = mainSql$sql,
                                        errorReportFile = file.path(getwd(),
          paste0("achillesError_", mainSql$analysisId, ".txt")))
          delta <- Sys.time() - start
          ParallelLogger::logInfo(sprintf("[Main Analysis] [COMPLETE] %d (%f %s)",
                                          as.integer(mainSql$analysisId),

          delta, attr(delta, "units")))
        }, error = function(e) {
          ParallelLogger::logError(sprintf("Analysis %d -- ERROR %s", mainSql$analysisId, e))
        })
      }
    } else {
      cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads,
                                             singleThreadToMain = TRUE)
      results <- ParallelLogger::clusterApply(cluster = cluster, x = mainSqls, function(mainSql) {
        start <- Sys.time()
        connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
        on.exit(DatabaseConnector::disconnect(connection = connection))
        ParallelLogger::logInfo(sprintf("[Main Analysis] [START] %d (%s)",
                                        as.integer(mainSql$analysisId),

          analysisDetails$ANALYSIS_NAME[analysisDetails$ANALYSIS_ID == mainSql$analysisId]))
        tryCatch({
          DatabaseConnector::executeSql(connection = connection,
                                        sql = mainSql$sql,
                                        errorReportFile = file.path(getwd(),
          paste0("achillesError_", mainSql$analysisId, ".txt")))
          delta <- Sys.time() - start
          ParallelLogger::logInfo(sprintf("[Main Analysis] [COMPLETE] %d (%f %s)",
                                          as.integer(mainSql$analysisId),

          delta, attr(delta, "units")))
        }, error = function(e) {
          ParallelLogger::logError(sprintf("[Main Analysis] [ERROR] %d (%s)",
                                           as.integer(mainSql$analysisId),

          e))
        })
      })

      ParallelLogger::stopCluster(cluster = cluster)
    }
  }

  # Merge scratch tables into final analysis tables
  # -------------------------------------------------------------------------------------------

  include <- sapply(resultsTables, function(d) {
    any(d$analysisIds %in% analysisDetails$ANALYSIS_ID)
  })
  resultsTablesToMerge <- resultsTables[include]

  mergeSqls <- lapply(resultsTablesToMerge, function(table) {
    .mergeAchillesScratchTables(resultsTable = table,
                                connectionDetails = connectionDetails,
                                analysisIds = analysisDetails$ANALYSIS_ID,

      createTable = createTable, schemaDelim = schemaDelim, scratchDatabaseSchema = scratchDatabaseSchema,
      resultsDatabaseSchema = resultsDatabaseSchema, tempEmulationSchema = tempEmulationSchema,
      cdmVersion = cdmVersion, tempAchillesPrefix = tempAchillesPrefix, numThreads = numThreads,
      smallCellCount = smallCellCount, outputFolder = outputFolder, sqlOnly = sqlOnly)
  })

  achillesSql <- c(achillesSql, mergeSqls)

  if (!sqlOnly) {
    ParallelLogger::logInfo("Merging scratch Achilles tables")

    if (numThreads == 1) {
      tryCatch({
        for (sql in mergeSqls) {
          DatabaseConnector::executeSql(connection = connection, sql = sql)
        }
      }, error = function(e) {
        ParallelLogger::logError(sprintf("Merging scratch Achilles tables [ERROR] (%s)", e))
      })
    } else {
      cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads,
                                             singleThreadToMain = TRUE)
      tryCatch({
        dummy <- ParallelLogger::clusterApply(cluster = cluster, x = mergeSqls, function(sql) {
          connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
          on.exit(DatabaseConnector::disconnect(connection = connection))
          DatabaseConnector::executeSql(connection = connection, sql = sql)
        })
      }, error = function(e) {
        ParallelLogger::logError(sprintf("Merging scratch Achilles tables (merging scratch Achilles tables) [ERROR] (%s)",
          e))
      })
      ParallelLogger::stopCluster(cluster = cluster)
    }
  }

  if (!sqlOnly) {
    ParallelLogger::logInfo(sprintf("Done. Achilles results can now be found in schema %s",
                                    resultsDatabaseSchema))
  }

  # Clean up scratch tables -----------------------------------------------

  if (numThreads == 1 && .supportsTempTables(connectionDetails) && !sqlOnly) {
    if (connectionDetails$dbms == "oracle") {
      ParallelLogger::logInfo(sprintf("Dropping scratch Achilles tables from schema %s",
                                      scratchDatabaseSchema))
      # Oracle TEMP tables are created as persistent tables and are given randomly generated string
      # prefixes preceding tempAchillesPrefix, therefore, they need their own code to drop the
      # scratch tables.

      allTables <- DatabaseConnector::getTableNames(connection, scratchDatabaseSchema)

      tablesToDrop <- c(allTables[which(grepl(tempAchillesPrefix, allTables, fixed = TRUE))],
                        allTables[which(grepl(tolower(tempAchillesPrefix),
        allTables, fixed = TRUE))], allTables[which(grepl(toupper(tempAchillesPrefix), allTables,
        fixed = TRUE))])

      dropSqls <- lapply(tablesToDrop, function(scratchTable) {
        sql <- SqlRender::render("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@scratchTable;\n",
          scratchDatabaseSchema = scratchDatabaseSchema, schemaDelim = schemaDelim, scratchTable = scratchTable)
        sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
      })

      dropSqls <- unlist(dropSqls)
      for (k in 1:length(dropSqls)) {
        DatabaseConnector::executeSql(connection, dropSqls[k])
      }
      ParallelLogger::logInfo(sprintf("Temporary Achilles tables removed from schema %s",
                                      scratchDatabaseSchema))

    } else {
      # For non-Oracle dbms, dropping the connection removes the temporary scratch tables if
      # running in serial
      DatabaseConnector::disconnect(connection = connection)
    }

  } else if (dropScratchTables & !sqlOnly) {
    # Drop the scratch tables
    ParallelLogger::logInfo(sprintf("Dropping scratch Achilles tables from schema %s",
                                    scratchDatabaseSchema))

    dropAllScratchTables(connectionDetails = connectionDetails,
                         scratchDatabaseSchema = scratchDatabaseSchema,

      tempAchillesPrefix = tempAchillesPrefix, numThreads = numThreads, tableTypes = c("achilles"),
      outputFolder = outputFolder, defaultAnalysesOnly = defaultAnalysesOnly)

    ParallelLogger::logInfo(sprintf("Temporary Achilles tables removed from schema %s",
                                    scratchDatabaseSchema))
  }

  # Create indices -----------------------------------------------------------------

  indicesSql <- "/* INDEX CREATION SKIPPED PER USER REQUEST */"

  if (createIndices) {
    achillesTables <- lapply(unique(analysisDetails$DISTRIBUTION), function(a) {
      if (a == 0) {
        "achilles_results"
      } else {
        "achilles_results_dist"
      }
    })
    indicesSql <- createIndices(connectionDetails = connectionDetails,
                                resultsDatabaseSchema = resultsDatabaseSchema,

      outputFolder = outputFolder, sqlOnly = sqlOnly, verboseMode = verboseMode, achillesTables = unique(achillesTables))
  }
  achillesSql <- c(achillesSql, indicesSql)

  # Optimize Atlas Cache -----------------------------------------------------------

  if (optimizeAtlasCache) {
    optimizeAtlasCacheSql <- optimizeAtlasCache(connectionDetails = connectionDetails,
                                                resultsDatabaseSchema = resultsDatabaseSchema,

      vocabDatabaseSchema = vocabDatabaseSchema, outputFolder = outputFolder, sqlOnly = sqlOnly,
      verboseMode = verboseMode, tempAchillesPrefix = tempAchillesPrefix)

    achillesSql <- c(achillesSql, optimizeAtlasCacheSql)
  }

  ParallelLogger::unregisterLogger("achilles")

  if (sqlOnly) {
    SqlRender::writeSql(sql = paste(achillesSql, collapse = "\n\n"),
                        targetFile = file.path(outputFolder,
      "achilles.sql"))
    ParallelLogger::logInfo(sprintf("All Achilles SQL scripts can be found in folder: %s",
                                    file.path(outputFolder,
      "achilles.sql")))
  }

  achillesResults <- list(resultsConnectionDetails = connectionDetails,
                          resultsTable = "achilles_results",

    resultsDistributionTable = "achilles_results_dist", analysis_table = "achilles_analysis", sourceName = sourceName,
    analysisIds = analysisDetails$ANALYSIS_ID, achillesSql = paste(achillesSql, collapse = "\n\n"),
    indicesSql = indicesSql, call = match.call())

  class(achillesResults) <- "achillesResults"

  invisible(achillesResults)

  totalDelta <- Sys.time() - totalStart
  ParallelLogger::logInfo(sprintf("[Total Runtime] %f %s", totalDelta, attr(totalDelta, "units")))
}


#' Create indicies
#'
#' @details
#' Post-processing, create indices to help performance. Cannot be used with Redshift.
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema   Fully qualified name of database schema that we can write final
#'                                results to. Default is cdmDatabaseSchema. On SQL Server, this should
#'                                specifiy both the database and the schema, so for example, on SQL
#'                                Server, 'cdm_results.dbo'.
#' @param outputFolder            Path to store logs and SQL files
#' @param sqlOnly                 TRUE = just generate SQL files, don't actually run, FALSE = run
#'                                Achilles
#' @param verboseMode             Boolean to determine if the console will show all execution steps.
#'                                Default = TRUE
#' @param achillesTables          Which achilles tables should be indexed? Default is both
#'                                achilles_results and achilles_results_dist.
#'
#' @export
createIndices <- function(connectionDetails,
                          resultsDatabaseSchema,
                          outputFolder,
                          sqlOnly = FALSE,
                          verboseMode = TRUE,

  achillesTables = c("achilles_results", "achilles_results_dist")) {
  # Log execution
  # --------------------------------------------------------------------------------------------------------------------

  unlink(file.path(outputFolder, "log_createIndices.txt"))
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_createIndices.txt")))
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_createIndices.txt")))
  }
  logger <- ParallelLogger::createLogger(name = "createIndices",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger)

  dropIndicesSql <- c()
  indicesSql <- c()

  # dbms specific index operations
  # -----------------------------------------------------------------------------------------

  if (connectionDetails$dbms %in% c("redshift", "netezza", "bigquery", "snowflake")) {
    return(sprintf("/* INDEX CREATION SKIPPED, INDICES NOT SUPPORTED IN %s */",
                   toupper(connectionDetails$dbms)))
  }

  if (connectionDetails$dbms == "pdw") {
    indicesSql <- c(indicesSql,
                    SqlRender::render("create clustered columnstore index ClusteredIndex_Achilles_results on @resultsDatabaseSchema.achilles_results;",
      resultsDatabaseSchema = resultsDatabaseSchema))
  }

  indices <- read.csv(file = system.file("csv",
                                         "post_processing",
                                         "indices.csv",
                                         package = "Achilles"),
    header = TRUE, stringsAsFactors = FALSE)

  # create index SQLs
  # ------------------------------------------------------------------------------------------------

  for (i in 1:nrow(indices)) {
    if (indices[i, ]$TABLE_NAME %in% achillesTables) {
      sql <- SqlRender::render(sql = "drop index @resultsDatabaseSchema.@indexName;",
                               resultsDatabaseSchema = resultsDatabaseSchema,

        indexName = indices[i, ]$INDEX_NAME)
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
      dropIndicesSql <- c(dropIndicesSql, sql)

      sql <- SqlRender::render(sql = "create index @indexName on @resultsDatabaseSchema.@tableName (@fields);",
        resultsDatabaseSchema = resultsDatabaseSchema, tableName = indices[i, ]$TABLE_NAME, indexName = indices[i,
          ]$INDEX_NAME, fields = paste(strsplit(x = indices[i, ]$FIELDS, split = "~")[[1]],
                                       collapse = ","))
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
      indicesSql <- c(indicesSql, sql)
    }
  }

  if (!sqlOnly) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection = connection))

    try(DatabaseConnector::executeSql(connection = connection,
                                      sql = paste(dropIndicesSql, collapse = "\n\n")),
      silent = TRUE)
    DatabaseConnector::executeSql(connection = connection,
                                  sql = paste(indicesSql, collapse = "\n\n"))
  }

  ParallelLogger::unregisterLogger("createIndices")

  invisible(c(dropIndicesSql, indicesSql))
}

#' Get all analysis details
#'
#' @details
#' Get a list of all analyses with their analysis IDs and strata.
#'
#' @return
#' A data.frame with the analysis details.
#'
#' @export
getAnalysisDetails <- function() {
  read.csv(system.file("csv", "achilles", "achilles_analysis_details.csv", package = "Achilles"),
           stringsAsFactors = FALSE)
}

#' Drop all possible scratch tables
#'
#' @details
#' Drop all possible Achilles scratch tables
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param scratchDatabaseSchema   string name of database schema that Achilles scratch tables were
#'                                written to.
#' @param tempAchillesPrefix      The prefix to use for the "temporary" (but actually permanent)
#'                                Achilles analyses tables. Default is "tmpach"
#' @param numThreads              The number of threads to use to run this function. Default is 1
#'                                thread.
#' @param tableTypes              The types of Achilles scratch tables to drop: achilles
#' @param outputFolder            Path to store logs and SQL files
#' @param verboseMode             Boolean to determine if the console will show all execution steps.
#'                                Default = TRUE
#' @param defaultAnalysesOnly     Boolean to determine if only default analyses should be run.
#'                                Including non-default analyses is substantially more resource
#'                                intensive.  Default = TRUE
#'
#' @export
dropAllScratchTables <- function(connectionDetails,
                                 scratchDatabaseSchema,
                                 tempAchillesPrefix = "tmpach",

  numThreads = 1, tableTypes = c("achilles"), outputFolder, verboseMode = TRUE, defaultAnalysesOnly = TRUE) {
  # Log execution
  # --------------------------------------------------------------------------------------------------------------------

  unlink(file.path(outputFolder, "log_dropScratchTables.txt"))
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_dropScratchTables.txt")))
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_dropScratchTables.txt")))
  }
  logger <- ParallelLogger::createLogger(name = "dropAllScratchTables",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger)

  # Initialize thread and scratchDatabaseSchema settings
  # ----------------------------------------------------------------

  schemaDelim <- "."

  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1

    if (.supportsTempTables(connectionDetails) && connectionDetails$dbms != "oracle") {
      scratchDatabaseSchema <- "#"
      schemaDelim <- "s_"
    }
  }

  if ("achilles" %in% tableTypes) {
    # Drop Achilles Scratch Tables ------------------------------------------------------

    analysisDetails <- getAnalysisDetails()

    if (defaultAnalysesOnly) {
      resultsTables <- lapply(analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION <= 0 & analysisDetails$IS_DEFAULT ==
        1], function(id) {
        sprintf("%s_%d", tempAchillesPrefix, id)
      })
    } else {
      resultsTables <- lapply(analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION <= 0],
                              function(id) {
        sprintf("%s_%d", tempAchillesPrefix, id)
      })
    }

    resultsDistTables <- lapply(analysisDetails$ANALYSIS_ID[abs(analysisDetails$DISTRIBUTION) ==
      1], function(id) {
      sprintf("%s_dist_%d", tempAchillesPrefix, id)
    })

    dropSqls <- lapply(c(resultsTables, resultsDistTables), function(scratchTable) {
      sql <- SqlRender::render("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@scratchTable;",
        scratchDatabaseSchema = scratchDatabaseSchema, schemaDelim = schemaDelim, scratchTable = scratchTable)
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    })

    cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- ParallelLogger::clusterApply(cluster = cluster, x = dropSqls, function(sql) {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      tryCatch({
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      }, error = function(e) {
        ParallelLogger::logError(sprintf("Drop Achilles Scratch Table -- ERROR (%s)", e))
      }, finally = {
        DatabaseConnector::disconnect(connection = connection)
      })
    })

    ParallelLogger::stopCluster(cluster = cluster)
  }

  ParallelLogger::unregisterLogger("dropAllScratchTables")
}

#' Optimize atlas cache
#'
#' @details
#' Post-processing, optimize data for atlas cache in separate table to help performance.
#'
#' @param connectionDetails       An R object of type \code{connectionDetails} created using the
#'                                function \code{createConnectionDetails} in the
#'                                \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema   Fully qualified name of database schema that we can write final
#'                                results to. Default is cdmDatabaseSchema. On SQL Server, this should
#'                                specifiy both the database and the schema, so for example, on SQL
#'                                Server, 'cdm_results.dbo'.
#' @param vocabDatabaseSchema     String name of database schema that contains OMOP Vocabulary. Default
#'                                is cdmDatabaseSchema. On SQL Server, this should specifiy both the
#'                                database and the schema, so for example 'results.dbo'.
#' @param outputFolder            Path to store logs and SQL files
#' @param sqlOnly                 TRUE = just generate SQL files, don't actually run, FALSE = run
#'                                Achilles
#' @param verboseMode             Boolean to determine if the console will show all execution steps.
#'                                Default = TRUE
#' @param tempAchillesPrefix      The prefix to use for the "temporary" (but actually permanent)
#'                                Achilles analyses tables. Default is "tmpach"
#'
#' @export
optimizeAtlasCache <- function(connectionDetails,
                               resultsDatabaseSchema,
                               vocabDatabaseSchema = resultsDatabaseSchema,

  outputFolder = "output", sqlOnly = FALSE, verboseMode = TRUE, tempAchillesPrefix = "tmpach") {
  if (!dir.exists(outputFolder)) {
    dir.create(path = outputFolder, recursive = TRUE)
  }
  # Log execution
  # --------------------------------------------------------------------------------------------------------------------

  unlink(file.path(outputFolder, "log_optimize_atlas_cache.txt"))
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_optimize_atlas_cache.txt")))
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel,
      fileName = file.path(outputFolder, "log_optimize_atlas_cache.txt")))
  }
  logger <- ParallelLogger::createLogger(name = "optimizeAtlasCache",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger)

  resultsConceptCountTable <- list(tablePrefix = tempAchillesPrefix,
                                   schema = read.csv(file = system.file("csv",
    "schemas", "schema_achilles_results_concept_count.csv", package = "Achilles"), header = TRUE))
  optimizeAtlasCacheSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/create_result_concept_table.sql",
    packageName = "Achilles", dbms = connectionDetails$dbms, resultsDatabaseSchema = resultsDatabaseSchema,
    vocabDatabaseSchema = vocabDatabaseSchema, fieldNames = paste(resultsConceptCountTable$schema$FIELD_NAME,
      collapse = ", "))
  if (!sqlOnly) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    tryCatch({
      ParallelLogger::logInfo("Optimizing atlas cache")
      DatabaseConnector::executeSql(connection = connection, sql = optimizeAtlasCacheSql)
      ParallelLogger::logInfo("Atlas cache was optimized")
    }, error = function(e) {
      ParallelLogger::logError(sprintf("Optimizing atlas cache [ERROR] (%s)", e))
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
    })
  }

  ParallelLogger::unregisterLogger("optimizeAtlasCache")

  invisible(optimizeAtlasCacheSql)
}

.getCdmVersion <- function(connectionDetails, cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_version from @cdmDatabaseSchema.cdm_source",
                           cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  cdmVersion <- tryCatch({
    c <- tolower((DatabaseConnector::querySql(connection = connection, sql = sql))[1, ])
    gsub(pattern = "v", replacement = "", x = c)
  }, error = function(e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })

  cdmVersion
}

.supportsTempTables <- function(connectionDetails) {
  !(connectionDetails$dbms %in% c("bigquery"))
}

.getAnalysisSql <- function(analysisId,
                            connectionDetails,
                            schemaDelim,
                            scratchDatabaseSchema,
                            cdmDatabaseSchema,

  resultsDatabaseSchema, tempEmulationSchema, cdmVersion, tempAchillesPrefix, resultsTables, sourceName,
  numThreads, outputFolder) {
  SqlRender::loadRenderTranslateSql(sqlFilename = file.path("analyses",
                                                            paste(analysisId, "sql", sep = ".")),
    packageName = "Achilles", dbms = connectionDetails$dbms, warnOnMissingParameters = FALSE, scratchDatabaseSchema = scratchDatabaseSchema,
    cdmDatabaseSchema = cdmDatabaseSchema, resultsDatabaseSchema = resultsDatabaseSchema, schemaDelim = schemaDelim,
    tempAchillesPrefix = tempAchillesPrefix, tempEmulationSchema = tempEmulationSchema, source_name = sourceName,
    achilles_version = packageVersion(pkg = "Achilles"), cdmVersion = cdmVersion, singleThreaded = (scratchDatabaseSchema ==
      "#"))
}

.mergeAchillesScratchTables <- function(resultsTable,
                                        analysisIds,
                                        createTable,
                                        connectionDetails,
                                        schemaDelim,
                                        scratchDatabaseSchema,
                                        resultsDatabaseSchema,
                                        tempEmulationSchema,
                                        cdmVersion,
                                        tempAchillesPrefix,
                                        numThreads,
                                        smallCellCount,
                                        outputFolder,
                                        sqlOnly) {
  castedNames <- apply(resultsTable$schema, 1, function(field) {
    SqlRender::render(
      "cast(@fieldName as @fieldType) as @fieldName",
      fieldName = field["FIELD_NAME"],
      fieldType = field["FIELD_TYPE"]
    )
  })

  # obtain the analysis SQLs to union in the merge
  # ------------------------------------------------------------------
  if (!sqlOnly) {
    logs <- .parseLogs(outputFolder)
  }
  detailSqls <- lapply(
    resultsTable$analysisIds[resultsTable$analysisIds %in% analysisIds],
    function(analysisId) {
      analysisSql <- SqlRender::render(
        sql = "select @castedNames from
                   @scratchDatabaseSchema@schemaDelim@tablePrefix_@analysisId",
        scratchDatabaseSchema = scratchDatabaseSchema, 
        schemaDelim = schemaDelim,
        castedNames = paste(castedNames, collapse = ", "),
        tablePrefix = resultsTable$tablePrefix,
        analysisId = analysisId
      )

      if (!sqlOnly) {
        # obtain the runTime for this analysis
        runTime <- .getAchillesResultBenchmark(analysisId, logs)

        benchmarkSelects <- lapply(resultsTable$schema$FIELD_NAME, function(c) {
          if (tolower(c) == "analysis_id") {
            sprintf("%d as analysis_id", .getBenchmarkOffset() + as.integer(analysisId))
          } else if (tolower(c) == "stratum_1") {
            sprintf("'%s' as stratum_1", runTime)
          } else if (tolower(c) == "count_value") {
            sprintf("%d as count_value", smallCellCount + 1)
          } else {
            sprintf("NULL as %s", c)
          }
        })

        benchmarkSql <- SqlRender::render(
          sql = "select @benchmarkSelect",
          benchmarkSelect = paste(benchmarkSelects, collapse = ", ")
        )

        analysisSql <- paste(c(analysisSql, benchmarkSql), collapse = " union all ")
      }
      analysisSql
    }
  )

  SqlRender::loadRenderTranslateSql(
    sqlFilename = "analyses/merge_achilles_tables.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    createTable = createTable,
    resultsDatabaseSchema = resultsDatabaseSchema,
    tempEmulationSchema = tempEmulationSchema,
    detailType = resultsTable$detailType,
    detailSqls = paste(detailSqls, collapse = " \nunion all\n "),
    fieldNames = paste(resultsTable$schema$FIELD_NAME, collapse = ", "),
    smallCellCount = smallCellCount
  )
}

.getSourceName <- function(connectionDetails, cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_source_name from @cdmDatabaseSchema.cdm_source",
                           cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sourceName <- tryCatch({
    s <- DatabaseConnector::querySql(connection = connection, sql = sql)
    s[1, ]
  }, error = function(e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  sourceName
}

.deleteExistingResults <- function(connectionDetails, resultsDatabaseSchema, analysisDetails) {
  resultIds <- analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION == 0]
  distIds <- analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION == 1]

  if (length(resultIds) > 0) {
    sql <- SqlRender::render(sql = "delete from @resultsDatabaseSchema.achilles_results where analysis_id in (@analysisIds);",
      resultsDatabaseSchema = resultsDatabaseSchema, analysisIds = paste(resultIds, collapse = ","))
    sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)

    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection = connection))
    DatabaseConnector::executeSql(connection = connection, sql = sql)
  }

  if (length(distIds) > 0) {
    sql <- SqlRender::render(sql = "delete from @resultsDatabaseSchema.achilles_results_dist where analysis_id in (@analysisIds);",
      resultsDatabaseSchema = resultsDatabaseSchema, analysisIds = paste(distIds, collapse = ","))
    sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection = connection))
    DatabaseConnector::executeSql(connection = connection, sql = sql)
  }
}

.deleteGivenAnalyses <- function(connectionDetails, resultsDatabaseSchema, analysisIds) {
  conn <- DatabaseConnector::connect(connectionDetails)

  sql <- "delete from @resultsDatabaseSchema.achilles_results where analysis_id in (@analysisIds);"
  sql <- SqlRender::render(sql,
                           resultsDatabaseSchema = resultsDatabaseSchema,
                           analysisIds = paste(analysisIds,
    collapse = ","))
  sql <- SqlRender::translate(sql, targetDialect = connectionDetails$dbms)

  DatabaseConnector::executeSql(conn, sql)

  sql <- "delete from @resultsDatabaseSchema.achilles_results_dist where analysis_id in (@analysisIds);"
  sql <- SqlRender::render(sql,
                           resultsDatabaseSchema = resultsDatabaseSchema,
                           analysisIds = paste(analysisIds,
    collapse = ","))
  sql <- SqlRender::translate(sql, targetDialect = connectionDetails$dbms)

  DatabaseConnector::executeSql(conn, sql)

  on.exit(DatabaseConnector::disconnect(conn))

}

.getAchillesResultBenchmark <- function(analysisId, logs) {
  logs <- logs[logs$analysisId == analysisId, ]
  if (nrow(logs) == 1) {
    runTime <- strsplit(logs[1, ]$runTime, " ")[[1]]
    runTimeValue <- round(as.numeric(runTime[1]), 2)
    runTimeUnit <- runTime[2]
    if (runTimeUnit == "mins") {
      runTimeValue <- runTimeValue * 60
    } else if (runTimeUnit == "hours") {
      runTimeValue <- runTimeValue * 60 * 60
    } else if (runTimeUnit == "days") {
      runTimeValue <- runTimeValue * 60 * 60 * 24
    }
    runTimeValue
  } else {
    "ERROR: no runtime found in log file"
  }
}

.parseLogs <- function(outputFolder) {
  logs <- utils::read.table(
      file = file.path(
          outputFolder,
          "log_achilles.txt"
      ),
      header = FALSE,
      sep = "\t",
      stringsAsFactors = FALSE
  )
  names(logs) <- c("startTime", "thread", "logType", "package", "packageFunction", "comment")
  logs <- logs[grepl(pattern = "COMPLETE", x = logs$comment), ]
  logs$analysisId <- logs$runTime <- NA

  for (i in 1:nrow(logs)) {
      logs[i, ]$analysisId <- .parseAnalysisId(logs[i, ]$comment)
      logs[i, ]$runTime <- .parseRunTime(logs[i, ]$comment)
  }
  logs
}

.formatName <- function(name) {
  gsub("_", " ", gsub("\\[(.*?)\\]_", "", gsub(" ", "_", name)))
}

.parseAnalysisId <- function(comment) {
  comment <- .formatName(comment)
  as.integer(gsub("\\s*\\([^\\)]+\\)", "", as.character(comment)))
}

.parseRunTime <- function(comment) {
  comment <- .formatName(comment)
  gsub("[\\(\\)]", "", regmatches(comment, gregexpr("\\(.*?\\)", comment))[[1]])
}

.getBenchmarkOffset <- function() {
  2e+06
}

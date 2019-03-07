# @file AchillesHeel
#
# Copyright 2019 Observational Health Data Sciences and Informatics
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
# @author Vojtech Huser
# @author Chris Knoll
# @author Ajit Londhe
# @author Taha Abdul-Basser



#' Execution of data quality rules (for v5 and above)
#'
#' @description
#' \code{achillesHeel} executes data quality rules (or checks) on pre-computed analyses (or measures).
#'
#' @details
#' \code{achillesHeel} contains number of rules (authored in SQL) that are executed against achilles results tables.
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           string name of database schema that contains OMOP CDM. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         string name of database schema that we can write final results to. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, 
#'                                         so for example 'results.dbo'.
#' @param scratchDatabaseSchema            (OPTIONAL, multi-threaded mode) Name of a fully qualified schema that is accessible to/from the resultsDatabaseSchema, that can store all of the scratch tables. Default is resultsDatabaseSchema.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above.  Default = "5". 
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempHeelPrefix                   (OPTIONAL, multi-threaded mode) The prefix to use for the "temporary" (but actually permanent) Heel tables. Default is "tmpheel"
#' @param dropScratchTables                (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place
#' @param ThresholdAgeWarning              The maximum age to allow in Heel
#' @param ThresholdOutpatientVisitPerc     The maximum percentage of outpatient visits among all visits
#' @param ThresholdMinimalPtMeasDxRx       The minimum percentage of patients with at least 1 Measurement, 1 Dx, and 1 Rx
#' @param sqlOnly                          Boolean to determine if Heel should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run Achilles Heel
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE  
#' 
#' @return The full Heel SQL code
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="some_server")
#'   achillesHeel <- achillesHeel(connectionDetails = connectionDetails, 
#'                                cdmDatabaseSchema = "cdm", 
#'                                resultsDatabaseSchema = "results", 
#'                                scratchDatabaseSchema = "scratch",
#'                                vocabDatabaseSchema = "vocab",
#'                                cdmVersion = "5.3.0",
#'                                numThreads = 10,
#'                                outputFolder = "output")
#' }
#' @export
achillesHeel <- function(connectionDetails, 
                         cdmDatabaseSchema, 
                         resultsDatabaseSchema = cdmDatabaseSchema,
                         scratchDatabaseSchema = resultsDatabaseSchema,
                         vocabDatabaseSchema = cdmDatabaseSchema,
                         cdmVersion = "5",
                         numThreads = 1,
                         tempHeelPrefix = "tmpheel",
                         dropScratchTables = FALSE,
                         ThresholdAgeWarning = 125,
                         ThresholdOutpatientVisitPerc = 0.43,
                         ThresholdMinimalPtMeasDxRx = 20.5,
                         outputFolder,
                         sqlOnly = FALSE,
                         verboseMode = TRUE) {
  
  # Try to get CDM Version if not provided ----------------------------------------------------------------------------------------
  
  if (missing(cdmVersion)) {
    cdmVersion <- .getCdmVersion(connectionDetails, cdmDatabaseSchema)
  }
  
  cdmVersion <- as.character(cdmVersion)
  
  # Check CDM version is valid ---------------------------------------------------------------------------------------------------
  
  if (compareVersion(a = cdmVersion, b = "5") < 0) {
    stop("Error: Invalid CDM Version number; this function is only for v5 and above. 
         See Achilles Git Repo to find v4 compatible version of Achilles.")
  }
  
  # Establish folder paths --------------------------------------------------------------------------------------------------------
  
  if (!dir.exists(outputFolder)) {
    dir.create(path = outputFolder, recursive = TRUE)
  }
  
  heelSql <- c()
  
  # Log execution --------------------------------------------------------------------------------------------------------------------
  
  unlink(file.path(outputFolder, "log_achillesHeel.txt"))
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_achillesHeel.txt")))    
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_achillesHeel.txt")))
  }
  logger <- ParallelLogger::createLogger(name = "achillesHeel",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger) 
  
  # Initialize thread and scratchDatabaseSchema settings ----------------------------------------------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    message("Beginning single-threaded operations")

    numThreads <- 1

    if (.supportsTempTables(connectionDetails)) {
      scratchDatabaseSchema <- "#"
      schemaDelim <- "s_"
    }

    ParallelLogger::logInfo("Beginning single-threaded execution")
    # first invocation of the connection, to persist throughout to maintain temp tables
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails) 
  } else if (!requireNamespace("ParallelLogger", quietly = TRUE)) {
    stop(
      "Multi-threading support requires package 'ParallelLogger'.",
      " Consider running single-threaded by setting",
      " `numThreads = 1` and `scratchDatabaseSchema = '#'`.",
      " You may install it using devtools with the following code:",
      "\n    devtools::install_github('OHDSI/ParallelLogger')",
      "\n\nAlternately, you might want to install ALL suggested packages using:",
      "\n    devtools::install_github('OHDSI/Achilles', dependencies = TRUE)",
      call. = FALSE
    )
  } else {
    ParallelLogger::logInfo("Beginning multi-threaded execution")
  }
  
  if (!sqlOnly) {
    ParallelLogger::logInfo("Executing Achilles Heel. This could take a while")  
  }
  
  # Clean up existing scratch tables -----------------------------------------------
  
  if ((numThreads > 1 || !.supportsTempTables(connectionDetails)) && !sqlOnly) {
    # Drop the scratch tables
    ParallelLogger::logInfo(sprintf("Dropping scratch Heel tables from schema %s", scratchDatabaseSchema))

    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads,
                         tableTypes = c("heel"),
                         outputFolder = outputFolder,
                         verboseMode = verboseMode)
    
    ParallelLogger::logInfo(sprintf("Temporary Heel tables removed from schema %s", scratchDatabaseSchema))
  }
  
  # Generate parallel Heels ---------------------------------------------------------------------------------------------------------
  
  parallelFiles <- list.files(path = file.path(system.file(package = "Achilles"), 
                                               "sql", "sql_server", "heels", "parallel"), 
                              recursive = TRUE, 
                              full.names = TRUE, 
                              all.files = FALSE,
                              pattern = "\\.sql$")
  
  parallelSqls <- lapply(parallelFiles, function(parallelFile) {
    .getHeelSql(heelFile = parallelFile,
                connectionDetails = connectionDetails,
                cdmDatabaseSchema = cdmDatabaseSchema,
                resultsDatabaseSchema = resultsDatabaseSchema,
                scratchDatabaseSchema = scratchDatabaseSchema,
                vocabDatabaseSchema = vocabDatabaseSchema,
                schemaDelim = schemaDelim,
                tempHeelPrefix = tempHeelPrefix,
                numThreads = numThreads,
                outputFolder = outputFolder)
  })
  
  heelSql <- c(heelSql, parallelSqls)
  
  if (!sqlOnly) {
    if (numThreads == 1) {
      for (sql in parallelSqls) {
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      }
    } else {
      cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      dummy <- ParallelLogger::clusterApply(cluster = cluster, 
                                         x = parallelSqls, 
                                         function(sql) {
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
      ParallelLogger::stopCluster(cluster = cluster)
    }
  }

  ParallelLogger::logInfo("Generated parallel Heels")
  
  # Merge scratch Heel tables into staging tables ----------------------------------------
  
  isDerived <- sapply(parallelFiles, function(parallelFile) { grepl(pattern = "derived", parallelFile) })
  
  derivedSqls <- lapply(parallelFiles[isDerived], function(parallelFile) {
    SqlRender::render(sql = 
                           "select 
                         cast(analysis_id as int) as analysis_id, 
                         cast(stratum_1 as varchar(255)) as stratum_1, 
                         cast(stratum_2 as varchar(255)) as stratum_2, 
                         cast(statistic_value as float) as statistic_value, 
                         cast(measure_id as varchar(255)) as measure_id
                         from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName", 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         schemaDelim = ifelse(scratchDatabaseSchema == "#", "s_", "."),
                         tempHeelPrefix = tempHeelPrefix,
                         heelName = gsub(pattern = ".sql", replacement = "", x = basename(parallelFile))) 
  })
  
  derivedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "heels/merge_derived.sql", 
                                                  packageName = "Achilles", 
                                                  dbms = connectionDetails$dbms,
                                                  warnOnMissingParameters = FALSE,
                                                  schema = scratchDatabaseSchema,
                                                  schemaDelim = ifelse(scratchDatabaseSchema == "#", "s_", "."),
                                                  destination = "achilles_rd_0",
                                                  derivedSqls = paste(derivedSqls, collapse = " \nunion all\n "))
  
  resultSqls <- lapply(X = parallelFiles[!isDerived], function(parallelFile) {
    SqlRender::render(sql = 
                           "select 
                         cast(analysis_id as int) as analysis_id, 
                         cast(ACHILLES_HEEL_warning as varchar(255)) as ACHILLES_HEEL_warning, 
                         cast(rule_id as int) as rule_id, 
                         cast(record_count as bigint) as record_count
                         from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName",
                         scratchDatabaseSchema = scratchDatabaseSchema,
                         schemaDelim = schemaDelim,
                         tempHeelPrefix = tempHeelPrefix,
                         heelName = gsub(pattern = ".sql", replacement = "", x = basename(parallelFile)))
  })
  
  resultSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "heels/merge_heel_results.sql", 
                                                 packageName = "Achilles", 
                                                 dbms = connectionDetails$dbms,
                                                 warnOnMissingParameters = FALSE,
                                                 schema = scratchDatabaseSchema,
                                                 schemaDelim = ifelse(scratchDatabaseSchema == "#", "s_", "."),
                                                 destination = "achilles_hr_0",
                                                 resultSqls = paste(resultSqls, collapse = " \nunion all\n "))
  
  heelSql <- c(heelSql, derivedSql, resultSql)
  
  if (!sqlOnly) {
    if (numThreads > 1) {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    }
    for (sql in c(derivedSql, resultSql)) {
      DatabaseConnector::executeSql(connection = connection, sql = sql)
    }
  }

  ParallelLogger::logInfo("Merged scratch Heel tables into staging tables")
  
  # Run serial queries to finish up ---------------------------------------------------
  
  serialFiles <- read.csv(file = system.file("csv", "heel", "heel_rules_all.csv", package = "Achilles"), 
                          header = TRUE, stringsAsFactors = FALSE)
  
  serialFiles <- serialFiles[serialFiles$execution_type == "serial", ]
  
  for (i in 1:nrow(serialFiles)) {
    row <- serialFiles[i,]
    newId <- rdOldId <- hrOldId <- as.integer(row$rule_id)
    
    if (i > 1) {
      rdOldId = as.integer(max(serialFiles$rule_id[serialFiles$destination_table %in% c("results_derived", "both") & 
                                                serialFiles$rule_id < newId]))
      hrOldId = as.integer(max(serialFiles$rule_id[serialFiles$destination_table %in% c("heel_results", "both") & 
                                                serialFiles$rule_id < newId]))
    }
    
    serialSql <- SqlRender::loadRenderTranslateSql(sqlFilename = sprintf("heels/serial/rule_%d.sql", 
                                                                         as.integer(row$rule_id)),
                                                   packageName = "Achilles",
                                                   dbms = connectionDetails$dbms,
                                                   schema = scratchDatabaseSchema,
                                                   schemaDelim = ifelse(scratchDatabaseSchema == "#", "s_", "."),
                                                   oracleTempSchema = scratchDatabaseSchema,
                                                   warnOnMissingParameters = FALSE,
                                                   resultsDatabaseSchema = resultsDatabaseSchema,
                                                   rdOldId = rdOldId,
                                                   hrOldId = hrOldId,
                                                   rdNewId = newId,
                                                   hrNewId = newId,
                                                   ThresholdAgeWarning = ThresholdAgeWarning,
                                                   ThresholdOutpatientVisitPerc = ThresholdOutpatientVisitPerc,
                                                   ThresholdMinimalPtMeasDxRx = ThresholdMinimalPtMeasDxRx)
    
    if (row$destination_table == "results_derived") {
      drops <- c(sprintf("rd_%d", rdOldId))
    } else if (row$destination_table == "heel_results") {
      drops <- c(sprintf("hr_%d", hrOldId))
    } else {
      drops <- c(sprintf("rd_%d", rdOldId), sprintf("hr_%d", hrOldId))
    }
    
    sqlDropPrior <- ""
    
    if (i > 1) {
      sqlDropPriors <- lapply(drops, function(drop) {
        sql <- SqlRender::render(sql = "IF OBJECT_ID('tempdb..#@table', 'U') IS NOT NULL DROP TABLE #@table;",
                             table = sprintf("serial_%2s", drop))
        sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms, oracleTempSchema = scratchDatabaseSchema)
      }) 
      sqlDropPrior <- paste(sqlDropPriors, collapse = "\n\n")
    }
    
    sql <- paste(serialSql, sqlDropPrior, sep = "\n\n")
    
    heelSql <- c(heelSql, sql)
    
    if (!sqlOnly) {
      DatabaseConnector::executeSql(connection = connection, sql = sql)
    }
  }
  
  # Create final Heel Tables ---------------------------------------------------
  
  rdId = as.integer(max(serialFiles$rule_id[serialFiles$destination_table %in% c("results_derived", "both")]))
  hrId = as.integer(max(serialFiles$rule_id[serialFiles$destination_table %in% c("heel_results", "both")]))
  
  sqlRd <- SqlRender::loadRenderTranslateSql(sqlFilename = "heels/merge_derived.sql", 
                                             packageName = "Achilles", 
                                             dbms = connectionDetails$dbms, 
                                             warnOnMissingParameters = FALSE,
                                             schema = resultsDatabaseSchema,
                                             schemaDelim = ".",
                                             destination = "achilles_results_derived",
                                             derivedSqls = SqlRender::translate(
                                                sql = sprintf("select * from #serial_rd_%d", rdId),
                                                targetDialect = connectionDetails$dbms, oracleTempSchema = scratchDatabaseSchema)
                                             )
  
  sqlHr <- SqlRender::loadRenderTranslateSql(sqlFilename = "heels/merge_heel_results.sql", 
                                             packageName = "Achilles", 
                                             dbms = connectionDetails$dbms, 
                                             warnOnMissingParameters = FALSE,
                                             schema = resultsDatabaseSchema,
                                             schemaDelim = ".",
                                             destination = "achilles_heel_results",
                                             resultSqls = SqlRender::translate(
                                                sql = sprintf("select * from #serial_hr_%d", hrId),
                                                targetDialect = connectionDetails$dbms, oracleTempSchema = scratchDatabaseSchema)
                                             )
  
  finalSqls <- c(sqlRd, sqlHr)
  heelSql <- c(heelSql, finalSqls)
  
  if (!sqlOnly) {
    for (sql in finalSqls) {
      DatabaseConnector::executeSql(connection = connection, sql = sql)
    }
  }
  
  
  # Clean up scratch parallel tables -----------------------------------------------
  
  if ((numThreads > 1 || !.supportsTempTables(connectionDetails)) && !sqlOnly) {
    # Drop the scratch tables
    ParallelLogger::logInfo(sprintf("Dropping scratch Heel tables from schema %s", scratchDatabaseSchema))

    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         tempHeelPrefix = tempHeelPrefix,
                         numThreads = numThreads,
                         tableTypes = c("heel"), 
                         outputFolder = outputFolder, 
                         verboseMode = verboseMode)
    
    ParallelLogger::logInfo(sprintf("Temporary Heel tables removed from schema %s", scratchDatabaseSchema))
  }
  
  heelSql <- paste(heelSql, collapse = "\n\n")
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = heelSql, targetFile = file.path(outputFolder, "achillesHeel.sql"))
    ParallelLogger::logInfo(sprintf("All Achilles SQL scripts can be found in folder: %s", file.path(outputFolder, "achillesHeel.sql")))
  } else {
    ParallelLogger::logInfo(sprintf("Done. Achilles Heel results can now be found in %s", resultsDatabaseSchema))
  }
  
  ParallelLogger::unregisterLogger("achillesHeel")

  heelResults <- list(resultsConnectionDetails = connectionDetails,
                      resultsTable = "achilles_heel_results",
                      heelSql = paste(heelSql, collapse = "\n\n"),
                      call = match.call())
  
  class(heelResults) <- "heelResults"
  
  invisible(heelResults)
}

.getHeelSql <- function(heelFile, 
                        connectionDetails, 
                        cdmDatabaseSchema,
                        resultsDatabaseSchema,
                        scratchDatabaseSchema,
                        vocabDatabaseSchema,
                        schemaDelim,
                        tempHeelPrefix, 
                        numThreads,
                        outputFolder) {
  
    SqlRender::loadRenderTranslateSql(sqlFilename = gsub(pattern = 
                                                                file.path(system.file(package = "Achilles"), 
                                                                          "sql/sql_server/"), 
                                                              replacement = "", x = heelFile),
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                           vocabDatabaseSchema = vocabDatabaseSchema,
                                           schemaDelim = schemaDelim,
                                           tempHeelPrefix = tempHeelPrefix,
                                           oracleTempSchema = scratchDatabaseSchema,
                                           heelName = gsub(pattern = ".sql", replacement = "", x = basename(heelFile)))
  
}

# @file Achilles
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


#' The main Achilles analyses (for v5.x)
#'
#' @description
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#'
#' @details
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM schema.
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema            Fully qualified name of the database schema that will store all of the intermediate scratch tables, so for example, on SQL Server, 'cdm_scratch.dbo'. 
#'                                         Must be accessible to/from the cdmDatabaseSchema and the resultsDatabaseSchema. Default is resultsDatabaseSchema. 
#'                                         Making this "#" will run Achilles in single-threaded mode and use temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param sourceName		                   String name of the data source name. If blank, CDM_SOURCE table will be queried to try to obtain this.
#' @param analysisIds		                   (OPTIONAL) A vector containing the set of Achilles analysisIds for which results will be generated. 
#'                                         If not specified, all analyses will be executed. Use \code{\link{getAnalysisDetails}} to get a list of all Achilles analyses and their Ids.
#' @param createTable                      If true, new results tables will be created in the results schema. If not, the tables are assumed to already exist, and analysis results will be inserted (slower on MPP).
#' @param smallCellCount                   To avoid patient identifiability, cells with small counts (<= smallCellCount) are deleted. Set to NULL if you don't want any deletions.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above. Use major release number or minor number only (e.g. 5, 5.3)
#' @param runHeel                          Boolean to determine if Achilles Heel data quality reporting will be produced based on the summary statistics.  Default = TRUE
#' @param validateSchema                   Boolean to determine if CDM Schema Validation should be run. Default = FALSE
#' @param runCostAnalysis                  Boolean to determine if cost analysis should be run. Note: only works on v5.1+ style cost tables.
#' @param createIndices                    Boolean to determine if indices should be created on the resulting Achilles and concept_hierarchy table. Default= TRUE
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param dropScratchTables                (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place for later removal.
#' @param sqlOnly                          Boolean to determine if Achilles should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE
#' @param conceptHierarchy                 (DEPRECATED) Boolean to determine if the concept_hierarchy result table should be created, for use by Atlas treemaps. Default is FALSE
#'                                         Please note: this table creation only requires the Vocabulary, not the CDM itself. 
#'                                         You could run this once for 1 Vocab version, and then copy the table to all CDMs using that Vocab.
#' 
#' @return                                 An object of type \code{achillesResults} containing details for connecting to the database containing the results 
#' @examples                               \dontrun{
#'                                           connectionDetails <- createConnectionDetails(dbms="sql server", server="some_server")
#'                                           achillesResults <- achilles(connectionDetails = connectionDetails, 
#'                                             cdmDatabaseSchema = "cdm", 
#'                                             resultsDatabaseSchema="results", 
#'                                             scratchDatabaseSchema="scratch",
#'                                             sourceName="Some Source", 
#'                                             cdmVersion = "5.3", 
#'                                             runCostAnalysis = TRUE, 
#'                                             numThreads = 10,
#'                                             outputFolder = "output")
#'                                         }
#' @export
achilles <- function (connectionDetails, 
                      cdmDatabaseSchema,
                      resultsDatabaseSchema = cdmDatabaseSchema, 
                      scratchDatabaseSchema = resultsDatabaseSchema,
                      vocabDatabaseSchema = cdmDatabaseSchema,
                      sourceName = "", 
                      analysisIds, 
                      createTable = TRUE,
                      smallCellCount = 5, 
                      cdmVersion = "5", 
                      runHeel = TRUE,
                      validateSchema = FALSE,
                      runCostAnalysis = FALSE,
                      createIndices = TRUE,
                      numThreads = 1,
                      tempAchillesPrefix = "tmpach",
                      dropScratchTables = TRUE,
                      sqlOnly = FALSE,
                      outputFolder = "output",
                      verboseMode = TRUE,
                      conceptHierarchy) {
  
  achillesSql <- c()
  
  # Log execution -----------------------------------------------------------------------------------------------------------------
  ParallelLogger::clearLoggers()
  unlink(file.path(outputFolder, "log_achilles.txt"))
  
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_achilles.txt")))    
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_achilles.txt")))
  }
  
  logger <- ParallelLogger::createLogger(name = "achilles",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger) 
  
  # handle deprecated parameters -------------------------------------------------------------------------------------------------
  
  if (!missing(conceptHierarchy)) {
    conceptHierarchyWarning <- "The conceptHierarchy parameter is deprecated, as the creation of this table is now handled in Atlas. However, you can still call the createConceptHierarchy function separately if needed."
    ParallelLogger::logWarn(conceptHierarchyWarning)
  }
  
  # Try to get CDM Version if not provided ----------------------------------------------------------------------------------------
  
  if (missing(cdmVersion)) {
    cdmVersion <- .getCdmVersion(connectionDetails, cdmDatabaseSchema)
  }
  
  cdmVersion <- as.character(cdmVersion)
  
  # Check CDM version is valid ---------------------------------------------------------------------------------------------------
  
  if (compareVersion(a = as.character(cdmVersion), b = "5") < 0) {
    stop("Error: Invalid CDM Version number; this function is only for v5 and above. 
         See Achilles Git Repo to find v4 compatible version of Achilles.")
  }
  
  # Establish folder paths --------------------------------------------------------------------------------------------------------
  
  if (!dir.exists(outputFolder)) {
    dir.create(path = outputFolder, recursive = TRUE)
  }
  
  # (optional) Validate CDM schema --------------------------------------------------------------------------------------------------
  
  if (validateSchema) {
    validateSchema(connectionDetails = connectionDetails, 
                   cdmDatabaseSchema = cdmDatabaseSchema, 
                   resultsDatabaseSchema = resultsDatabaseSchema,
                   runCostAnalysis = runCostAnalysis, 
                   cdmVersion = cdmVersion, 
                   outputFolder = outputFolder, 
                   sqlOnly = sqlOnly)
  }
  
  # Get source name if none provided ----------------------------------------------------------------------------------------------
  
  if (missing(sourceName) & !sqlOnly) {
    .getSourceName(connectionDetails, cdmDatabaseSchema)
  }
  
  # Obtain analyses to run --------------------------------------------------------------------------------------------------------
  
  analysisDetails <- getAnalysisDetails()
  costIds <- analysisDetails$ANALYSIS_ID[analysisDetails$COST == 1]
  
  if (!missing(analysisIds)) {
    analysisDetails <- analysisDetails[analysisDetails$ANALYSIS_ID %in% analysisIds, ]
    
    # determine if cost analysis ids have been selected
    runCostAnalysis <- any(analysisIds %in% costIds)
  }
  
  if (!runCostAnalysis) {
    analysisDetails <- analysisDetails[analysisDetails$COST == 0, ]
  }
  
  # Check if cohort table is present ---------------------------------------------------------------------------------------------
  
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  
  sql <- SqlRender::render("select top 1 cohort_definition_id from @resultsDatabaseSchema.cohort;", 
                              resultsDatabaseSchema = resultsDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  
  cohortTableExists <- tryCatch({
    dummy <- DatabaseConnector::querySql(connection = connection, sql = sql)
    TRUE
  }, error = function(e) {
    ParallelLogger::logWarn("Cohort table not found, will skip analyses 1700 and 1701")
    FALSE
  })
  DatabaseConnector::disconnect(connection = connection)
  
  if (!cohortTableExists) {
    analysisDetails <- analysisDetails[!analysisDetails$ANALYSIS_ID %in% c(1700,1701),]
  }
  
  resultsTables <- list(
    list(detailType = "results",
                  tablePrefix = tempAchillesPrefix, 
                  schema = read.csv(file = system.file("csv", "schemas", "schema_achilles_results.csv", package = "Achilles"), 
                           header = TRUE),
                  analysisIds = analysisDetails[analysisDetails$DISTRIBUTION <= 0, ]$ANALYSIS_ID),
    list(detailType = "results_dist",
                      tablePrefix = sprintf("%1s_%2s", tempAchillesPrefix, "dist"),
                      schema = read.csv(file = system.file("csv", "schemas", "schema_achilles_results_dist.csv", package = "Achilles"), 
                           header = TRUE),
                      analysisIds = analysisDetails[abs(analysisDetails$DISTRIBUTION) == 1, ]$ANALYSIS_ID))
  
  # Initialize thread and scratchDatabaseSchema settings and verify ParallelLogger installed ---------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
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
  
  # Check if createTable is FALSE and no analysisIds specified -----------------------------------------------------
  
  if (!createTable & missing(analysisIds)) {
    createTable <- TRUE
  }
  
  ## Remove existing results if createTable is FALSE ----------------------------------------------------------------
  
  if (!createTable) {
    .deleteExistingResults(connectionDetails = connectionDetails, 
                           analysisDetails = analysisDetails)  
  }
  
  # Create analysis table -------------------------------------------------------------
  
  if (createTable) {
    analysesSqls <- apply(analysisDetails, 1, function(analysisDetail) {  
      SqlRender::render("select @analysisId as analysis_id, '@analysisName' as analysis_name,
                           '@stratum1Name' as stratum_1_name, '@stratum2Name' as stratum_2_name,
                           '@stratum3Name' as stratum_3_name, '@stratum4Name' as stratum_4_name,
                           '@stratum5Name' as stratum_5_name", 
                           analysisId = analysisDetail["ANALYSIS_ID"],
                           analysisName = analysisDetail["ANALYSIS_NAME"],
                           stratum1Name = analysisDetail["STRATUM_1_NAME"],
                           stratum2Name = analysisDetail["STRATUM_2_NAME"],
                           stratum3Name = analysisDetail["STRATUM_3_NAME"],
                           stratum4Name = analysisDetail["STRATUM_4_NAME"],
                           stratum5Name = analysisDetail["STRATUM_5_NAME"])
    })  
    
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/create_analysis_table.sql", 
                                             packageName = "Achilles", 
                                             dbms = connectionDetails$dbms,
                                             warnOnMissingParameters = FALSE,
                                             resultsDatabaseSchema = resultsDatabaseSchema,
                                             analysesSqls = paste(analysesSqls, collapse = " \nunion all\n "))
    
    achillesSql <- c(achillesSql, sql)
    
    if (!sqlOnly) {
      if (numThreads == 1) { 
        # connection is already alive
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      } else {
        connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
        DatabaseConnector::executeSql(connection = connection, sql = sql)
        DatabaseConnector::disconnect(connection = connection)
      }
    }
  }

  # Clean up existing scratch tables -----------------------------------------------

  if ((numThreads > 1 || !.supportsTempTables(connectionDetails)) && !sqlOnly) {
    # Drop the scratch tables
    ParallelLogger::logInfo(sprintf("Dropping scratch Achilles tables from schema %s", scratchDatabaseSchema))

    dropAllScratchTables(connectionDetails = connectionDetails,
                         scratchDatabaseSchema = scratchDatabaseSchema,
                         tempAchillesPrefix = tempAchillesPrefix,
                         numThreads = numThreads,
                         tableTypes = c("achilles", "concept_hierarchy"),
                         outputFolder = outputFolder)

    ParallelLogger::logInfo(sprintf("Temporary Achilles tables removed from schema %s", scratchDatabaseSchema))
  }
  
  # Generate cost analyses ----------------------------------------------------------
  
  if (runCostAnalysis) {
    
    distCostAnalysisDetails <- analysisDetails[analysisDetails$COST == 1 & analysisDetails$DISTRIBUTION == 1, ]
    costMappings <- read.csv(system.file("csv", "achilles", "achilles_cost_columns.csv", package = "Achilles"), 
                             header = TRUE, stringsAsFactors = FALSE)
    
    drugCostMappings <- costMappings[costMappings$DOMAIN == "Drug", ]
    procedureCostMappings <- costMappings[costMappings$DOMAIN == "Procedure", ]
    
    ## Create raw cost tables before generating cost analyses
    
    rawCostSqls <- lapply(c("Drug", "Procedure"), function(domainId) {
      costMappings <- get(sprintf("%sCostMappings", tolower(domainId)))
      
      if (cdmVersion == "5") { 
        costColumns <- apply(costMappings, 1, function(c) {
          sprintf("%1s as %2s", c["OLD"], c["CURRENT"])
        })
      } else {
        costColumns <- costMappings$CURRENT
      }
      list(
        analysisId = ifelse(domainId == "Drug", 15000, 16000),
        sql = SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/raw_cost_template.sql", 
                                                packageName = "Achilles", 
                                                dbms = connectionDetails$dbms,
                                                warnOnMissingParameters = FALSE,
                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                scratchDatabaseSchema = scratchDatabaseSchema,
                                                oracleTempSchema = scratchDatabaseSchema,
                                                schemaDelim = schemaDelim,
                                                tempAchillesPrefix = tempAchillesPrefix,
                                                domainId = domainId,
                                                domainTable = ifelse(domainId == "Drug", "drug_exposure", "procedure_occurrence"), 
                                                costColumns = paste(costColumns, collapse = ","))
      )
    })
    
    achillesSql <- c(achillesSql, rawCostSqls)
    
    if (!sqlOnly & length(rawCostSqls) > 0) {
      if (numThreads == 1) {
        for (rawCostSql in rawCostSqls) {
          start <- Sys.time()
          ParallelLogger::logInfo(sprintf("[Raw Cost] [START] %s", 
                                          rawCostSql$analysisId))
          DatabaseConnector::executeSql(connection = connection, sql = rawCostSql$sql)
          delta <- Sys.time() - start
          ParallelLogger::logInfo(sprintf("[Raw Cost] [COMPLETE] %s (%f %s)", 
                                          rawCostSql$analysisId, 
                                          delta, 
                                          attr(delta, "units")))
        }
      } else {
        cluster <- ParallelLogger::makeCluster(numberOfThreads = length(rawCostSqls), 
                                            singleThreadToMain = TRUE)
        results <- ParallelLogger::clusterApply(cluster = cluster, 
                                             x = rawCostSqls, 
                                             function(rawCostSql) {
                                               start <- Sys.time()
                                               ParallelLogger::logInfo(sprintf("[Raw Cost] [START] %s", rawCostSql$analysisId))
                                               connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                               on.exit(DatabaseConnector::disconnect(connection = connection))
                                               DatabaseConnector::executeSql(connection = connection, sql = rawCostSql$sql)
                                               delta <- Sys.time() - start
                                               ParallelLogger::logInfo(sprintf("[Raw Cost] [COMPLETE] %s (%f %s)", 
                                                                               rawCostSql$analysisId, 
                                                                               delta,
                                                                               attr(delta, "units")))
                                             })
        
        ParallelLogger::stopCluster(cluster = cluster) 
      }
    }
    
    distCostDrugSqls <- 
      apply(distCostAnalysisDetails[distCostAnalysisDetails$STRATUM_1_NAME == "drug_concept_id", ], 1, 
            function (analysisDetail) {
              list(analysisId = analysisDetail["ANALYSIS_ID"][[1]],
                   sql = SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/cost_distribution_template.sql",
                                                           packageName = "Achilles",
                                                           dbms = connectionDetails$dbms,
                                                           warnOnMissingParameters = FALSE,
                                                           cdmVersion = cdmVersion,
                                                           schemaDelim = schemaDelim,
                                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                                           oracleTempSchema = scratchDatabaseSchema,
                                                           costColumn = drugCostMappings[drugCostMappings$OLD == analysisDetail["DISTRIBUTED_FIELD"][[1]], ]$CURRENT,
                                                           domainId = "Drug",
                                                           domainTable = "drug_exposure", 
                                                           analysisId = analysisDetail["ANALYSIS_ID"][[1]],
                                                           tempAchillesPrefix = tempAchillesPrefix)
              )
              })
    
    distCostProcedureSqls <- 
      apply(distCostAnalysisDetails[distCostAnalysisDetails$STRATUM_1_NAME == "procedure_concept_id", ], 1,
            function (analysisDetail) {
              list(analysisId = analysisDetail["ANALYSIS_ID"][[1]],
                   sql = SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/cost_distribution_template.sql",
                                                           packageName = "Achilles",
                                                           dbms = connectionDetails$dbms,
                                                           warnOnMissingParameters = FALSE,
                                                           cdmVersion = cdmVersion,
                                                           schemaDelim = schemaDelim,
                                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                                           oracleTempSchema = scratchDatabaseSchema,
                                                           costColumn = procedureCostMappings[procedureCostMappings$OLD == analysisDetail["DISTRIBUTED_FIELD"][[1]], ]$CURRENT,
                                                           domainId = "Procedure",
                                                           domainTable = "procedure_occurrence", 
                                                           analysisId = analysisDetail["ANALYSIS_ID"][[1]],
                                                           tempAchillesPrefix = tempAchillesPrefix)
              )
              })
    
    distCostAnalysisSqls <- c(distCostDrugSqls, distCostProcedureSqls)
    
    achillesSql <- c(achillesSql, lapply(distCostAnalysisSqls, function(s) s$sql))
    
    if (!sqlOnly & length(distCostAnalysisSqls) > 0) {
      if (numThreads == 1) {
        for (distCostAnalysisSql in distCostAnalysisSqls) {
          start <- Sys.time()
          ParallelLogger::logInfo(sprintf("[Cost Analysis] [START] %d", 
                                          as.integer(distCostAnalysisSql$analysisId)))
          DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql$sql)
          delta <- Sys.time() - start
          ParallelLogger::logInfo(sprintf("[Cost Analysis] [COMPLETE] %d (%f %s)", 
                                          as.integer(distCostAnalysisSql$analysisId), 
                                          delta,
                                          attr(delta, "units")))
        }
      } else {
        cluster <- ParallelLogger::makeCluster(numberOfThreads = length(distCostAnalysisSqls), 
                                            singleThreadToMain = TRUE)
        results <- ParallelLogger::clusterApply(cluster = cluster, 
                                           x = distCostAnalysisSqls, 
                                           function(distCostAnalysisSql) {
                                             start <- Sys.time()
                                             ParallelLogger::logInfo(sprintf("[Cost Analysis] [START] %d", 
                                                                             as.integer(distCostAnalysisSql$analysisId)))
                                             connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                             on.exit(DatabaseConnector::disconnect(connection = connection))
                                             DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql$sql)
                                             delta <- Sys.time() - start
                                             ParallelLogger::logInfo(sprintf("[Cost Analysis] [COMPLETE] %d (%f %s)", 
                                                                             as.integer(distCostAnalysisSql$analysisId), 
                                                                             delta,
                                                                             attr(delta, "units")))
                                           })
        ParallelLogger::stopCluster(cluster = cluster) 
      }
    }
  }
  
  # Generate Main Analyses ----------------------------------------------------------------------------------------------------------------
  
  mainAnalysisIds <- analysisDetails$ANALYSIS_ID
  if (runCostAnalysis) {
    # remove distributed cost analysis ids, since that's been executed already
    mainAnalysisIds <- dplyr::anti_join(x = analysisDetails, y = distCostAnalysisDetails, by = "ANALYSIS_ID")$ANALYSIS_ID
  }
  mainSqls <- lapply(mainAnalysisIds, function(analysisId) {
    list(analysisId = analysisId,
         sql = .getAnalysisSql(analysisId = analysisId,
                               connectionDetails = connectionDetails,
                               schemaDelim = schemaDelim,
                               scratchDatabaseSchema = scratchDatabaseSchema,
                               cdmDatabaseSchema = cdmDatabaseSchema,
                               resultsDatabaseSchema = resultsDatabaseSchema,
                               cdmVersion = cdmVersion,
                               tempAchillesPrefix = tempAchillesPrefix,
                               resultsTables = resultsTables,
                               sourceName = sourceName,
                               numThreads = numThreads,
                               outputFolder = outputFolder)
    )
  })
  
  achillesSql <- c(achillesSql, lapply(mainSqls, function(s) s$sql))
    
  if (!sqlOnly) {
    ParallelLogger::logInfo("Executing multiple queries. This could take a while")
    
    if (numThreads == 1) {
      for (mainSql in mainSqls) {
        start <- Sys.time()
        ParallelLogger::logInfo(sprintf("Analysis %d (%s) -- START", mainSql$analysisId, 
                                        analysisDetails$ANALYSIS_NAME[analysisDetails$ANALYSIS_ID == mainSql$analysisId]))
        tryCatch({
          DatabaseConnector::executeSql(connection = connection, sql = mainSql$sql)
          delta <- Sys.time() - start
          ParallelLogger::logInfo(sprintf("[Main Analysis] [COMPLETE] %d (%f %s)", 
                                          as.integer(mainSql$analysisId), 
                                          delta, 
                                          attr(delta, "units")))  
        }, error = function(e) {
          ParallelLogger::logError(sprintf("Analysis %d -- ERROR %s", mainSql$analysisId, e))
        })
      }
    } else {
      cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      results <- ParallelLogger::clusterApply(cluster = cluster, 
                                         x = mainSqls, 
                                         function(mainSql) {
                                           start <- Sys.time()
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           on.exit(DatabaseConnector::disconnect(connection = connection))
                                           ParallelLogger::logInfo(sprintf("[Main Analysis] [START] %d (%s)", 
                                                                           as.integer(mainSql$analysisId), 
                                                                           analysisDetails$ANALYSIS_NAME[analysisDetails$ANALYSIS_ID == mainSql$analysisId]))
                                           tryCatch({
                                             DatabaseConnector::executeSql(connection = connection, sql = mainSql$sql)
                                             delta <- Sys.time() - start
                                             ParallelLogger::logInfo(sprintf("[Main Analysis] [COMPLETE] %d (%f %s)", 
                                                                             as.integer(mainSql$analysisId), 
                                                                             delta, 
                                                                             attr(delta, "units")))  
                                           }, error = function(e) {
                                             ParallelLogger::logError(sprintf("[Main Analysis] [ERROR] %d (%s)", 
                                                                              as.integer(mainSql$analysisId), 
                                                                              e))
                                           })
                                         })
      
      ParallelLogger::stopCluster(cluster = cluster)
    }
  }
  
  # Merge scratch tables into final analysis tables -------------------------------------------------------------------------------------------
  
  include <- sapply(resultsTables, function(d) { any(d$analysisIds %in% analysisDetails$ANALYSIS_ID) })
  resultsTablesToMerge <- resultsTables[include]
  
  mergeSqls <- lapply(resultsTablesToMerge, function(table) {
    .mergeAchillesScratchTables(resultsTable = table,
                               connectionDetails = connectionDetails,
                               analysisIds = analysisDetails$ANALYSIS_ID,
                               createTable = createTable,
                               schemaDelim = schemaDelim,
                               scratchDatabaseSchema = scratchDatabaseSchema,
                               resultsDatabaseSchema = resultsDatabaseSchema,
                               cdmVersion = cdmVersion,
                               tempAchillesPrefix = tempAchillesPrefix,
                               numThreads = numThreads,
                               smallCellCount = smallCellCount,
                               outputFolder = outputFolder,
                               sqlOnly = sqlOnly,
                               includeRawCost = ifelse(table$detailType == "results_dist", runCostAnalysis, FALSE))
  })
  
  achillesSql <- c(achillesSql, mergeSqls)

  if (!sqlOnly) {
    
    ParallelLogger::logInfo("Merging scratch Achilles tables")
    
    if (numThreads == 1) {
      for (sql in mergeSqls) {
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      }
    } else {
      cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      dummy <- ParallelLogger::clusterApply(cluster = cluster, 
                                         x = mergeSqls, 
                                         function(sql) {
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           on.exit(DatabaseConnector::disconnect(connection = connection))
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)
                                         })
      ParallelLogger::stopCluster(cluster = cluster)
    }
  }
  
  if (!sqlOnly) {
    ParallelLogger::logInfo(sprintf("Done. Achilles results can now be found in schema %s", resultsDatabaseSchema))
  }
  
  # Clean up scratch tables -----------------------------------------------
  
  if (numThreads == 1 & .supportsTempTables(connectionDetails)) {
    # Dropping the connection removes the temporary scratch tables if running in serial
    DatabaseConnector::disconnect(connection = connection)
  } else if (dropScratchTables & !sqlOnly) {
    # Drop the scratch tables
    ParallelLogger::logInfo(sprintf("Dropping scratch Achilles tables from schema %s", scratchDatabaseSchema))
   
    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads,
                         tableTypes = c("achilles"),
                         outputFolder = outputFolder)
    
    ParallelLogger::logInfo(sprintf("Temporary Achilles tables removed from schema %s", scratchDatabaseSchema))
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
                                outputFolder = outputFolder,
                                sqlOnly = sqlOnly,
                                verboseMode = verboseMode, 
                                achillesTables = unique(achillesTables))
  }
  achillesSql <- c(achillesSql, indicesSql)
  
  # Run Heel? ---------------------------------------------------------------
  
  heelSql <- "/* HEEL EXECUTION SKIPPED PER USER REQUEST */"
  if (runHeel) {
    heelResults <- achillesHeel(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                scratchDatabaseSchema = scratchDatabaseSchema,
                                vocabDatabaseSchema = vocabDatabaseSchema,
                                cdmVersion = cdmVersion,
                                sqlOnly = sqlOnly,
                                numThreads = numThreads,
                                tempHeelPrefix = "tmpheel",
                                dropScratchTables = dropScratchTables,
                                outputFolder = outputFolder,
                                verboseMode = verboseMode)
    heelSql <- heelResults$heelSql
  }
  
  ParallelLogger::unregisterLogger("achilles")
  
  achillesSql <- c(achillesSql, heelSql)
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = paste(achillesSql, collapse = "\n\n"), targetFile = file.path(outputFolder, "achilles.sql"))
    ParallelLogger::logInfo(sprintf("All Achilles SQL scripts can be found in folder: %s", file.path(outputFolder, "achilles.sql")))
  }

  achillesResults <- list(resultsConnectionDetails = connectionDetails,
                          resultsTable = "achilles_results",
                          resultsDistributionTable = "achilles_results_dist",
                          analysis_table = "achilles_analysis",
                          sourceName = sourceName,
                          analysisIds = analysisDetails$ANALYSIS_ID,
                          achillesSql = paste(achillesSql, collapse = "\n\n"),
                          heelSql = heelSql,
                          indicesSql = indicesSql,
                          call = match.call())
  
  class(achillesResults) <- "achillesResults"
  
  invisible(achillesResults)
}

#' (DEPRECATED) Create the concept hierarchy
#' 
#' @details 
#' This function is no longer necessary for Atlas Data Sources, as its functionality is handled by WebAPI.
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema            Fully qualified name of the database schema that will store all of the intermediate scratch tables, so for example, on SQL Server, 'cdm_scratch.dbo'. 
#'                                         Must be accessible to/from the cdmDatabaseSchema and the resultsDatabaseSchema. Default is resultsDatabaseSchema. 
#'                                         Making this "#" will run Achilles in single-threaded mode and use temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param outputFolder                     Path to store logs and SQL files
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE 
#' 
#' @export
createConceptHierarchy <- function(connectionDetails, 
                                   resultsDatabaseSchema,
                                   scratchDatabaseSchema,
                                   vocabDatabaseSchema,
                                   outputFolder,
                                   numThreads = 1,
                                   tempAchillesPrefix = "tmpach",
                                   sqlOnly = FALSE,
                                   verboseMode = TRUE) {
  
  .Deprecated(msg = "'createConceptHierarchy' will be removed in the next version of Achilles. The concept_hierarchy table creation is now handled in Atlas.")
  
  # Log execution --------------------------------------------------------------------------------------------------------------------
  
  unlink(file.path(outputFolder, "log_conceptHierarchy.txt"))
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_conceptHierarchy.txt")))    
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_conceptHierarchy.txt")))
  }
  
  logger <- ParallelLogger::createLogger(name = "conceptHierarchy",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger) 
  
  # Initialize thread and scratchDatabaseSchema settings ----------------------------------------------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1
    
    if (.supportsTempTables(connectionDetails)) {
      scratchDatabaseSchema <- "#"
      schemaDelim <- "s_"
    }
  }
  
  hierarchySqlFiles <- list.files(path = file.path(system.file(package = "Achilles"), 
                                                   "sql", "sql_server", "post_processing", "concept_hierarchies"), 
                                  recursive = TRUE, 
                                  full.names = FALSE, 
                                  all.files = FALSE,
                                  pattern = "\\.sql$")
  
  hierarchySqls <- lapply(hierarchySqlFiles, function(hierarchySqlFile) {
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("post_processing", 
                                                                     "concept_hierarchies", 
                                                                     hierarchySqlFile),
                                             packageName = "Achilles",
                                             dbms = connectionDetails$dbms,
                                             warnOnMissingParameters = FALSE,
                                             scratchDatabaseSchema = scratchDatabaseSchema,
                                             oracleTempSchema = scratchDatabaseSchema,
                                             vocabDatabaseSchema = vocabDatabaseSchema,
                                             schemaDelim = schemaDelim,
                                             tempAchillesPrefix = tempAchillesPrefix)
  })
  
  mergeSql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("post_processing", 
                                                                        "merge_concept_hierarchy.sql"),
                                                packageName = "Achilles",
                                                dbms = connectionDetails$dbms,
                                                warnOnMissingParameters = FALSE,
                                                resultsDatabaseSchema = resultsDatabaseSchema,
                                                scratchDatabaseSchema = scratchDatabaseSchema,
                                                oracleTempSchema = scratchDatabaseSchema,
                                                schemaDelim = schemaDelim,
                                                tempAchillesPrefix = tempAchillesPrefix)
  
  
  if (!sqlOnly) {
    ParallelLogger::logInfo("Executing Concept Hierarchy creation. This could take a while")
    
    if (numThreads == 1) {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      for (sql in hierarchySqls) {
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      }
      DatabaseConnector::executeSql(connection = connection, sql = mergeSql)
      DatabaseConnector::disconnect(connection = connection)
    } else {
      cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      dummy <- ParallelLogger::clusterApply(cluster = cluster, 
                                            x = hierarchySqls, 
                                            function(sql) {
                                              connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                              DatabaseConnector::executeSql(connection = connection, sql = sql)
                                              DatabaseConnector::disconnect(connection = connection)
                                            })
      ParallelLogger::stopCluster(cluster = cluster)
      
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      DatabaseConnector::executeSql(connection = connection, sql = mergeSql)
      DatabaseConnector::disconnect(connection = connection)
    }
    
    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads,
                         tableTypes = c("concept_hierarchy"),
                         outputFolder = outputFolder)
    
    ParallelLogger::logInfo(sprintf("Done. Concept Hierarchy table can now be found in %s", resultsDatabaseSchema))  
  }
  
  ParallelLogger::unregisterLogger("conceptHierarchy")
  
  invisible(c(hierarchySqls, mergeSql))
}


#' Create indicies
#' 
#' @details 
#' Post-processing, create indices to help performance. Cannot be used with Redshift.
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param outputFolder                     Path to store logs and SQL files
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE 
#' @param achillesTables                   Which achilles tables should be indexed? Default is both achilles_results and achilles_results_dist. 
#' 
#' @export
createIndices <- function(connectionDetails,
                          resultsDatabaseSchema,
                          outputFolder,
                          sqlOnly = FALSE,
                          verboseMode = TRUE,
                          achillesTables = c("achilles_results", "achilles_results_dist")) {
  
  # Log execution --------------------------------------------------------------------------------------------------------------------
  
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
  
  # dbms specific index operations -----------------------------------------------------------------------------------------
  
  if (connectionDetails$dbms %in% c("redshift", "netezza", "bigquery")) {
    return (sprintf("/* INDEX CREATION SKIPPED, INDICES NOT SUPPORTED IN %s */", toupper(connectionDetails$dbms)))
  }
  
  if (connectionDetails$dbms == "pdw") {
    indicesSql <- c(indicesSql, 
                    SqlRender::render("create clustered columnstore index ClusteredIndex_Achilles_results on @resultsDatabaseSchema.achilles_results;",
                                         resultsDatabaseSchema = resultsDatabaseSchema))
  }
  
  indices <- read.csv(file = system.file("csv", "post_processing", "indices.csv", package = "Achilles"), 
                      header = TRUE, stringsAsFactors = FALSE)
  
  # create index SQLs ------------------------------------------------------------------------------------------------  
    
  for (i in 1:nrow(indices)) {
    if (indices[i,]$TABLE_NAME %in% achillesTables) {
      sql <- SqlRender::render(sql = "drop index @resultsDatabaseSchema.@indexName;",
                                  resultsDatabaseSchema = resultsDatabaseSchema,
                                  indexName = indices[i,]$INDEX_NAME)
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
      dropIndicesSql <- c(dropIndicesSql, sql)
      
      sql <- SqlRender::render(sql = "create index @indexName on @resultsDatabaseSchema.@tableName (@fields);",
                                  resultsDatabaseSchema = resultsDatabaseSchema,
                                  tableName = indices[i,]$TABLE_NAME,
                                  indexName = indices[i,]$INDEX_NAME,
                                  fields = paste(strsplit(x = indices[i,]$FIELDS, split = "~")[[1]], collapse = ","))
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
      indicesSql <- c(indicesSql, sql)
    }
  }
  
  if (!sqlOnly) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection = connection))
    
    try(DatabaseConnector::executeSql(connection = connection, sql = paste(dropIndicesSql, collapse = "\n\n")), silent = TRUE)
    DatabaseConnector::executeSql(connection = connection, 
                                  sql = paste(indicesSql, collapse = "\n\n"))
  }
  
  ParallelLogger::unregisterLogger("createIndices")
  
  invisible(c(dropIndicesSql, indicesSql))
}



#' Validate the CDM schema
#' 
#' @details 
#' Runs a validation script to ensure the CDM is valid based on v5.x
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param cdmDatabaseSchema    	           string name of database schema that contains OMOP CDM. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that the cohort table is written to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above. Use major release number or minor number only (e.g. 5, 5.3)
#' @param runCostAnalysis                  Boolean to determine if cost analysis should be run. Note: only works on CDM v5 and v5.1.0+ style cost tables.
#' @param outputFolder                     Path to store logs and SQL files
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE  
#' 
#' @export
validateSchema <- function(connectionDetails,
                           cdmDatabaseSchema,
                           resultsDatabaseSchema = cdmDatabaseSchema,
                           cdmVersion,
                           runCostAnalysis,
                           outputFolder,
                           sqlOnly = FALSE,
                           verboseMode = TRUE) {
  
  # Log execution --------------------------------------------------------------------------------------------------------------------
  
  unlink(file.path(outputFolder, "log_validateSchema.txt"))
  if (verboseMode) {
    appenders <- list(ParallelLogger::createConsoleAppender(),
                      ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_validateSchema.txt")))    
  } else {
    appenders <- list(ParallelLogger::createFileAppender(layout = ParallelLogger::layoutParallel, 
                                                         fileName = file.path(outputFolder, "log_validateSchema.txt")))
  }
  logger <- ParallelLogger::createLogger(name = "validateSchema",
                                         threshold = "INFO",
                                         appenders = appenders)
  ParallelLogger::registerLogger(logger) 
  
  majorVersions <- lapply(c("5", "5.1", "5.2", "5.3"), function(majorVersion) {
    if (compareVersion(a = as.character(cdmVersion), b = majorVersion) >= 0) {
      majorVersion
    } else {
      0
    }
  })
  
  cdmVersion <- max(unlist(majorVersions))

  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "validate_schema.sql", 
                                           packageName = "Achilles", 
                                           dbms = connectionDetails$dbms,
                                           warnOnMissingParameters = FALSE,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           runCostAnalysis = runCostAnalysis,
                                           cdmVersion = cdmVersion)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "ValidateSchema.sql")) 
  } else {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    tables <- DatabaseConnector::querySql(connection = connection, sql = sql)
    ParallelLogger::logInfo("CDM Schema is valid")
    DatabaseConnector::disconnect(connection = connection)
  }
  
  ParallelLogger::unregisterLogger("validateSchema")
  invisible(sql)
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
  read.csv( 
    system.file(
      "csv", 
      "achilles", 
      "achilles_analysis_details.csv", 
      package = "Achilles"),
    stringsAsFactors = FALSE
  )
}

#' Drop all possible scratch tables
#' 
#' @details 
#' Drop all possible Achilles, Heel, and Concept Hierarchy scratch tables
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param scratchDatabaseSchema            string name of database schema that Achilles scratch tables were written to. 
#' @param tempAchillesPrefix               The prefix to use for the "temporary" (but actually permanent) Achilles analyses tables. Default is "tmpach"
#' @param tempHeelPrefix                   The prefix to use for the "temporary" (but actually permanent) Heel tables. Default is "tmpheel"
#' @param numThreads                       The number of threads to use to run this function. Default is 1 thread.
#' @param tableTypes                       The types of Achilles scratch tables to drop: achilles or heel or concept_hierarchy or all 3
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE  
#' 
#' @export
dropAllScratchTables <- function(connectionDetails, 
                                 scratchDatabaseSchema, 
                                 tempAchillesPrefix = "tmpach", 
                                 tempHeelPrefix = "tmpheel", 
                                 numThreads = 1,
                                 tableTypes = c("achilles", "heel", "concept_hierarchy"),
                                 outputFolder,
                                 verboseMode = TRUE) {
  
  # Log execution --------------------------------------------------------------------------------------------------------------------
  
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
  
  
  # Initialize thread and scratchDatabaseSchema settings ----------------------------------------------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1

    if (.supportsTempTables(connectionDetails)) {
      scratchDatabaseSchema <- "#"
      schemaDelim <- "s_"
    }
  }

  if ("achilles" %in% tableTypes) {
  
    # Drop Achilles Scratch Tables ------------------------------------------------------
    
    analysisDetails <- getAnalysisDetails()
    
    resultsTables <- lapply(analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION <= 0], function(id) {
      sprintf("%s_%d", tempAchillesPrefix, id)
    })
    
    resultsDistTables <- lapply(analysisDetails$ANALYSIS_ID[abs(analysisDetails$DISTRIBUTION) == 1], function(id) {
      sprintf("%s_dist_%d", tempAchillesPrefix, id)
    })
    
    dropSqls <- lapply(c(resultsTables, resultsDistTables), function(scratchTable) {
      sql <- SqlRender::render("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@scratchTable;", 
                                  scratchDatabaseSchema = scratchDatabaseSchema,
                                  schemaDelim = schemaDelim,
                                  scratchTable = scratchTable)
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    })
    
    dropRawCostSqls <- lapply(c("Drug", "Procedure"), function(domainId) {
      sql <- SqlRender::render(sql = "IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw;",
                               scratchDatabaseSchema = scratchDatabaseSchema,
                               schemaDelim = schemaDelim,
                               tempAchillesPrefix = tempAchillesPrefix,
                               domainId = domainId)
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    })
    
    dropSqls <- c(dropSqls, dropRawCostSqls)
    
    cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- ParallelLogger::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
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
  
  if ("heel" %in% tableTypes) {
    # Drop Parallel Heel Scratch Tables ------------------------------------------------------
    
    parallelFiles <- list.files(path = file.path(system.file(package = "Achilles"), 
                                         "sql/sql_server/heels/parallel"), 
                            recursive = TRUE, 
                            full.names = FALSE, 
                            all.files = FALSE,
                            pattern = "\\.sql$")
    
    parallelHeelTables <- lapply(parallelFiles, function(t) tolower(paste(tempHeelPrefix,
                                                                          trimws(tools::file_path_sans_ext(basename(t))),
                                                                    sep = "_")))
  
    dropSqls <- lapply(parallelHeelTables, function(scratchTable) {
      sql <- SqlRender::render("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@scratchTable;", 
                           scratchDatabaseSchema = scratchDatabaseSchema,
                           schemaDelim = schemaDelim,
                           scratchTable = scratchTable)
      sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    })
    
    cluster <- ParallelLogger::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- ParallelLogger::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
                                         connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                         tryCatch({
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)  
                                         }, error = function(e) {
                                           ParallelLogger::logError(sprintf("Drop Heel Scratch Table -- ERROR (%s)", e))  
                                         }, finally = {
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
                                       })
    
    ParallelLogger::stopCluster(cluster = cluster)
  }
  
  ParallelLogger::unregisterLogger("dropAllScratchTables")
}

.getCdmVersion <- function(connectionDetails, 
                           cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_version from @cdmDatabaseSchema.cdm_source",
                              cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  cdmVersion <- tryCatch({
    c <- tolower((DatabaseConnector::querySql(connection = connection, sql = sql))[1,])
    gsub(pattern = "v", replacement = "", x = c)
  }, error = function (e) {
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
                            resultsDatabaseSchema,
                            cdmVersion,
                            tempAchillesPrefix, 
                            resultsTables,
                            sourceName,
                            numThreads,
                            outputFolder) {
  
  SqlRender::loadRenderTranslateSql(sqlFilename = file.path("analyses", paste(analysisId, "sql", sep = ".")),
                                         packageName = "Achilles",
                                         dbms = connectionDetails$dbms,
                                         warnOnMissingParameters = FALSE,
                                         scratchDatabaseSchema = scratchDatabaseSchema,
                                         cdmDatabaseSchema = cdmDatabaseSchema,
                                         resultsDatabaseSchema = resultsDatabaseSchema,
                                         schemaDelim = schemaDelim,
                                         tempAchillesPrefix = tempAchillesPrefix,
                                         oracleTempSchema = scratchDatabaseSchema,
                                         source_name = sourceName,
                                         achilles_version = packageVersion(pkg = "Achilles"),
                                         cdmVersion = cdmVersion,
                                         singleThreaded = (scratchDatabaseSchema == "#"))
}

.mergeAchillesScratchTables <- function(resultsTable,
                                        analysisIds,
                                        createTable,
                                        connectionDetails,
                                        schemaDelim,
                                        scratchDatabaseSchema,
                                        resultsDatabaseSchema, 
                                        cdmVersion,
                                        tempAchillesPrefix,
                                        numThreads,
                                        smallCellCount,
                                        outputFolder,
                                        sqlOnly,
                                        includeRawCost) {
  
  castedNames <- apply(resultsTable$schema, 1, function(field) {
    SqlRender::render("cast(@fieldName as @fieldType) as @fieldName", 
                         fieldName = field["FIELD_NAME"],
                         fieldType = field["FIELD_TYPE"])
  })
  
  # obtain the analysis SQLs to union in the merge ------------------------------------------------------------------
  
  detailSqls <- lapply(resultsTable$analysisIds[resultsTable$analysisIds %in% analysisIds], function(analysisId) { 
    analysisSql <- SqlRender::render(sql = "select @castedNames from 
                                     @scratchDatabaseSchema@schemaDelim@tablePrefix_@analysisId", 
                                     scratchDatabaseSchema = scratchDatabaseSchema,
                                     schemaDelim = schemaDelim,
                                     castedNames = paste(castedNames, collapse = ", "), 
                                     tablePrefix = resultsTable$tablePrefix, 
                                     analysisId = analysisId)
    
    if (!sqlOnly) {
      # obtain the runTime for this analysis
      runTime <- .getAchillesResultBenchmark(analysisId,
                                             outputFolder)
      
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
      
      benchmarkSql <- SqlRender::render(sql = "select @benchmarkSelect",
                                        benchmarkSelect = paste(benchmarkSelects, collapse = ", "))
      
      analysisSql <- paste(c(analysisSql, benchmarkSql), collapse = " union all ")
      
    } 
    SqlRender::translate(sql = analysisSql, targetDialect = connectionDetails$dbms)
  })
  
  if (!sqlOnly & includeRawCost) {
    # obtain the runTime for this analysis
    
    benchmarkSqls <- lapply(c(15000, 16000), function(rawCostId) {
      runTime <- .getAchillesResultBenchmark(rawCostId, outputFolder)  
    
      benchmarkSelects <- lapply(resultsTable$schema$FIELD_NAME, function(c) {
        if (tolower(c) == "analysis_id") {
          sprintf("%d as analysis_id", .getBenchmarkOffset() + rawCostId)
        } else if (tolower(c) == "stratum_1") {
          sprintf("'%s' as stratum_1", runTime)
        } else if (tolower(c) == "count_value") {
          sprintf("%d as count_value", smallCellCount + 1) 
        } else {
          sprintf("NULL as %s", c)
        }
      })
      SqlRender::render(sql = "select @benchmarkSelect", benchmarkSelect = paste(benchmarkSelects, collapse = ", "))
    })
    benchmarkSql <- paste(benchmarkSqls, collapse = " union all ")
    benchmarkSql <- SqlRender::translate(sql = benchmarkSql, targetDialect = connectionDetails$dbms)
    detailSqls <- c(detailSqls, benchmarkSql)
  }
  
  SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/merge_achilles_tables.sql",
                                    packageName = "Achilles",
                                    dbms = connectionDetails$dbms,
                                    warnOnMissingParameters = FALSE,
                                    createTable = createTable,
                                    resultsDatabaseSchema = resultsDatabaseSchema,
                                    detailType = resultsTable$detailType,
                                    detailSqls = paste(detailSqls, collapse = " \nunion all\n "),
                                    fieldNames = paste(resultsTable$schema$FIELD_NAME, collapse = ", "),
                                    smallCellCount = smallCellCount)
}

.getSourceName <- function(connectionDetails,
                           cdmDatabaseSchema) {
  sql <- SqlRender::render(sql = "select cdm_source_name from @cdmDatabaseSchema.cdm_source",
                              cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sourceName <- tryCatch({
    s <- DatabaseConnector::querySql(connection = connection, sql = sql)
    s[1,]
  }, error = function (e) {
    ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    rm(connection)
  })
  sourceName
}

.deleteExistingResults <- function(connectionDetails,
                                   analysisDetails) {
  
  
  resultIds <- analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION == 0]
  distIds <- analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION == 1]
  
  if (length(resultIds) > 0) {
    sql <- SqlRender::render(sql = "delete from @resultsDatabaseSchema.achilles_results where analysis_id in (@analysisIds);",
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                analysisIds = paste(resultIds, collapse = ","))
    sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection = connection))
    DatabaseConnector::executeSql(connection = connection, sql = sql)
  }
  
  if (length(distIds) > 0) {
    sql <- SqlRender::render(sql = "delete from @resultsDatabaseSchema.achilles_results_dist where analysis_id in (@analysisIds);",
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                analysisIds = paste(distIds, collapse = ","))
    sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection = connection))
    DatabaseConnector::executeSql(connection = connection, sql = sql)
  }
}

.getAchillesResultBenchmark <- function(analysisId,
                                        outputFolder) {
  
  logs <- read.table(file = file.path(outputFolder, "log_achilles.txt"), 
                     header = FALSE, sep = "\t", stringsAsFactors = FALSE)
  names(logs) <- c("startTime", "thread", "logType", "package", "packageFunction", "comment")
  logs <- logs[grepl(pattern = "COMPLETE", x = logs$comment),]
  logs$analysisId <- logs$runTime <- NA
  
  for (i in 1:nrow(logs)) {
    logs[i,]$analysisId <- .getAnalysisId(logs[i,]$comment)
    logs[i,]$runTime <- .getRunTime(logs[i,]$comment)
  }
  
  logs <- logs[logs$analysisId == analysisId,]
  if (nrow(logs) == 1) {
    logs[1,]$runTime
  } else {
    "ERROR: check log files"
  }
}

.formatName <- function(name) {
  gsub("_", " ", gsub("\\[(.*?)\\]_", "", gsub(" ", "_", name)))
}

.getAnalysisId <- function(comment) {
  comment <- .formatName(comment)
  as.integer(gsub("\\s*\\([^\\)]+\\)","", as.character(comment)))
}

.getRunTime <- function(comment) {
  comment <- .formatName(comment)
  gsub("[\\(\\)]", "", regmatches(comment, gregexpr("\\(.*?\\)", comment))[[1]])
}

.getBenchmarkOffset <- function() {
  2000000
}
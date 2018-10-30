# @file Achilles
#
# Copyright 2018 Observational Health Data Sciences and Informatics
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
#' @param conceptHierarchy                 Boolean to determine if the concept_hierarchy result table should be created, for use by Atlas treemaps. Default is FALSE
#'                                         Please note: this table creation only requires the Vocabulary, not the CDM itself. 
#'                                         You could run this once for 1 Vocab version, and then copy the table to all CDMs using that Vocab.
#' @param createIndices                    Boolean to determine if indices should be created on the resulting Achilles and concept_hierarchy table. Default= TRUE
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param dropScratchTables                (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place for later removal.
#' @param sqlOnly                          Boolean to determine if Achilles should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     Path to store logs and SQL files
#' @param verboseMode                      Boolean to determine if the console will show all execution steps. Default = TRUE
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
                      conceptHierarchy = FALSE,
                      createIndices = TRUE,
                      numThreads = 1,
                      tempAchillesPrefix = "tmpach",
                      dropScratchTables = TRUE,
                      sqlOnly = FALSE,
                      outputFolder = "output",
                      verboseMode = TRUE) {
  
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
  if (!missing(analysisIds)) {
    analysisDetails <- analysisDetails[analysisDetails$ANALYSIS_ID %in% analysisIds, ]
  }
  
  if (!runCostAnalysis) {
    analysisDetails <- analysisDetails[analysisDetails$COST == 0, ]
  }
  
  # Check if cohort table is present ---------------------------------------------------------------------------------------------
  
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  
  sql <- SqlRender::renderSql("select top 1 cohort_definition_id from @resultsDatabaseSchema.cohort;", 
                              resultsDatabaseSchema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
  
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
  
  # Initialize thread and scratchDatabaseSchema settings and verify OhdsiRTools installed ---------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1
    scratchDatabaseSchema <- "#"
    schemaDelim <- "s_"
    
    ParallelLogger::logInfo("Beginning single-threaded execution")
    
    # first invocation of the connection, to persist throughout to maintain temp tables
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails) 
  } else if (!requireNamespace("OhdsiRTools", quietly = TRUE)) {
    stop(
      "Multi-threading support requires package 'OhdsiRTools'.",
      " Consider running single-threaded by setting",
      " `numThreads = 1` and `scratchDatabaseSchema = '#'`.",
      " You may install it using devtools with the following code:",
      "\n    devtools::install_github('OHDSI/OhdsiRTools')",
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
      SqlRender::renderSql("select @analysisId as analysis_id, '@analysisName' as analysis_name,
                           '@stratum1Name' as stratum_1_name, '@stratum2Name' as stratum_2_name,
                           '@stratum3Name' as stratum_3_name, '@stratum4Name' as stratum_4_name,
                           '@stratum5Name' as stratum_5_name", 
                           analysisId = analysisDetail["ANALYSIS_ID"],
                           analysisName = analysisDetail["ANALYSIS_NAME"],
                           stratum1Name = analysisDetail["STRATUM_1_NAME"],
                           stratum2Name = analysisDetail["STRATUM_2_NAME"],
                           stratum3Name = analysisDetail["STRATUM_3_NAME"],
                           stratum4Name = analysisDetail["STRATUM_4_NAME"],
                           stratum5Name = analysisDetail["STRATUM_5_NAME"])$sql
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
        analysisId = domainId,
        sql = SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/raw_cost_template.sql", 
                                                packageName = "Achilles", 
                                                dbms = connectionDetails$dbms,
                                                warnOnMissingParameters = FALSE,
                                                cdmDatabaseSchema = cdmDatabaseSchema,
                                                scratchDatabaseSchema = scratchDatabaseSchema,
                                                schemaDelim = schemaDelim,
                                                tempAchillesPrefix = tempAchillesPrefix,
                                                domainId = domainId,
                                                domainTable = ifelse(domainId == "Drug", "drug_exposure", "procedure_occurrence"), 
                                                costColumns = paste(costColumns, collapse = ","))
      )
    })
    
    achillesSql <- c(achillesSql, rawCostSqls)
    
    if (!sqlOnly) {
      if (numThreads == 1) {
        for (rawCostSql in rawCostSqls) {
          start <- Sys.time()
          ParallelLogger::logInfo(sprintf("Raw Cost %d: START", rawCostSql$analysisId))
          DatabaseConnector::executeSql(connection = connection, sql = rawCostSql$sql)
          ParallelLogger::logInfo(sprintf("Raw Cost %d: COMPLETE (%f seconds)", rawCostSql$analysisId, Sys.time() - start))
        }
      } else {
        cluster <- OhdsiRTools::makeCluster(numberOfThreads = length(rawCostSqls), 
                                            singleThreadToMain = TRUE)
        results <- OhdsiRTools::clusterApply(cluster = cluster, 
                                             x = rawCostSqls, 
                                             function(rawCostSql) {
                                               start <- Sys.time()
                                               ParallelLogger::logInfo(sprintf("Raw Cost %d: START", rawCostSql$analysisId))
                                               connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                               DatabaseConnector::executeSql(connection = connection, sql = rawCostSql$sql)
                                               DatabaseConnector::disconnect(connection = connection)
                                               ParallelLogger::logInfo(sprintf("Raw Cost %d: COMPLETE (%f seconds)", rawCostSql$analysisId, Sys.time() - start))
                                             })
        
        OhdsiRTools::stopCluster(cluster = cluster) 
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
                                                           costColumn = procedureCostMappings[procedureCostMappings$OLD == analysisDetail["DISTRIBUTED_FIELD"][[1]], ]$CURRENT,
                                                           domainId = "Procedure",
                                                           domainTable = "procedure_occurrence", 
                                                           analysisId = analysisDetail["ANALYSIS_ID"][[1]],
                                                           tempAchillesPrefix = tempAchillesPrefix)
              )
              })
    
    distCostAnalysisSqls <- c(distCostDrugSqls, distCostProcedureSqls)
    
    dropRawCostSqls <- lapply(c("Drug", "Procedure"), function(domainId) {
      SqlRender::renderSql(sql = "drop table @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_@domainId_cost_raw;",
                           scratchDatabaseSchema = scratchDatabaseSchema,
                           schemaDelim = schemaDelim,
                           tempAchillesPrefix = tempAchillesPrefix,
                           domainId = domainId)$sql
    })
    
    achillesSql <- c(achillesSql, lapply(distCostAnalysisSqls, function(s) s$sql), dropRawCostSqls)
    
    if (!sqlOnly) {
      if (numThreads == 1) {
        for (distCostAnalysisSql in distCostAnalysisSqls) {
          start <- Sys.time()
          ParallelLogger::logInfo(sprintf("Cost Analysis %d: START", distCostAnalysisSql$analysisId))
          DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql$sql)
          ParallelLogger::logInfo(sprintf("Cost Analysis %d: COMPLETE (%f seconds)", distCostAnalysisSql$analysisId, 
                                  Sys.time() - start))
        }
        for (dropRawCostSql in dropRawCostSqls) {
          DatabaseConnector::executeSql(connection = connection, sql = dropRawCostSql)
        }
      } else {
        cluster <- OhdsiRTools::makeCluster(numberOfThreads = length(distCostAnalysisSqls), 
                                            singleThreadToMain = TRUE)
        results <- OhdsiRTools::clusterApply(cluster = cluster, 
                                           x = distCostAnalysisSqls, 
                                           function(distCostAnalysisSql) {
                                             start <- Sys.time()
                                             ParallelLogger::logInfo(sprintf("Cost Analysis %d: START", distCostAnalysisSql$analysisId))
                                             connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                             DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql$sql)
                                             DatabaseConnector::disconnect(connection = connection)
                                             ParallelLogger::logInfo(sprintf("Cost Analysis %d: COMPLETE (%f seconds)", distCostAnalysisSql$analysisId, 
                                                                             Sys.time() - start))
                                           })
        
        OhdsiRTools::stopCluster(cluster = cluster) 
        
        cluster <- OhdsiRTools::makeCluster(numberOfThreads = length(dropRawCostSqls), 
                                            singleThreadToMain = TRUE)
        dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                           x = dropRawCostSqls, 
                                           function(dropRawCostSql) {
                                             connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                             DatabaseConnector::executeSql(connection = connection, sql = dropRawCostSql)
                                             DatabaseConnector::disconnect(connection = connection)
                                           })
        OhdsiRTools::stopCluster(cluster = cluster) 
      }
    }
  }
  
  # Clean up existing scratch tables -----------------------------------------------
  
  if (numThreads > 1 & !sqlOnly) {
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
          ParallelLogger::logInfo(sprintf("Analysis %d -- COMPLETE (%f %s)", mainSql$analysisId, delta, attr(delta, "units")))  
        }, error = function(e) {
          ParallelLogger::logError(sprintf("Analysis %d -- ERROR %s", mainSql$analysisId, e))
        })
      }
    } else {
      cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      results <- OhdsiRTools::clusterApply(cluster = cluster, 
                                         x = mainSqls, 
                                         function(mainSql) {
                                           start <- Sys.time()
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           ParallelLogger::logInfo(sprintf("Main Analysis %d (%s) -- START", mainSql$analysisId, 
                                                                           analysisDetails$ANALYSIS_NAME[analysisDetails$ANALYSIS_ID == mainSql$analysisId]))
                                           tryCatch({
                                             DatabaseConnector::executeSql(connection = connection, sql = mainSql$sql)
                                             delta <- Sys.time() - start
                                             ParallelLogger::logInfo(sprintf("Main Analysis %d -- COMPLETE (%f %s)", mainSql$analysisId, delta, attr(delta, "units")))  
                                           }, error = function(e) {
                                             ParallelLogger::logError(sprintf("Analysis %d -- ERROR %s", mainSql$analysisId, e))
                                           }, finally = function(f) {
                                             DatabaseConnector::disconnect(connection = connection)
                                           })
                                         })
      
      OhdsiRTools::stopCluster(cluster = cluster)
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
                               outputFolder = outputFolder)
  })
  
  achillesSql <- c(achillesSql, mergeSqls)

  if (!sqlOnly) {
    
    ParallelLogger::logInfo("Merging scratch Achilles tables")
    
    if (numThreads == 1) {
      for (sql in mergeSqls) {
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      }
    } else {
      cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                         x = mergeSqls, 
                                         function(sql) {
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
      OhdsiRTools::stopCluster(cluster = cluster)
    }
  }
  
  if (!sqlOnly) {
    ParallelLogger::logInfo(sprintf("Done. Achilles results can now be found in schema %s", resultsDatabaseSchema))
  }
  
  # Clean up scratch tables -----------------------------------------------
  
  if (numThreads == 1) {
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
  
  # Create concept hierarchy table -----------------------------------------------------------------
  
  hierarchySql <- "/* CONCEPT HIERARCHY EXECUTION SKIPPED PER USER REQUEST */"
  if (conceptHierarchy) {
    hierarchySql <- createConceptHierarchy(connectionDetails = connectionDetails, 
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                           vocabDatabaseSchema = vocabDatabaseSchema,
                                           numThreads = numThreads,
                                           tempAchillesPrefix = tempAchillesPrefix,
                                           sqlOnly = sqlOnly,
                                           outputFolder = outputFolder,
                                           verboseMode = verboseMode)
  }
  achillesSql <- c(achillesSql, hierarchySql)

  
  # Create indices -----------------------------------------------------------------
  
  indicesSql <- "/* INDEX CREATION SKIPPED PER USER REQUEST */"
  
  if (createIndices) {
    indicesSql <- createIndices(connectionDetails = connectionDetails,
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                outputFolder = outputFolder,
                                sqlOnly = sqlOnly,
                                verboseMode = verboseMode)    
  }
  achillesSql <- c(achillesSql, indicesSql)
  
  # Run Heel? ---------------------------------------------------------------
  
  heelSql <- "/* HEEL EXECUTION SKIPPED PER USER REQUEST */"
  if (runHeel) {
    heelResults <- achillesHeel(connectionDetails = connectionDetails,
                                cdmDatabaseSchema = cdmDatabaseSchema,
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                scratchDatabaseSchema = scratchDatabaseSchema,
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
                          hierarchySql = hierarchySql,
                          indicesSql = indicesSql,
                          call = match.call())
  
  class(achillesResults) <- "achillesResults"
  
  invisible(achillesResults)
}

#' Create the concept hierarchy
#' 
#' @details 
#' Post-processing, create the concept hierarchy.
#' Please note: this table creation only requires the Vocabulary, not the CDM itself. 
#' You could run this once for 1 Vocab version, and then copy the table to all CDMs using that Vocab.
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
    scratchDatabaseSchema <- "#"
    schemaDelim <- "s_"
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
      cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                         x = hierarchySqls, 
                                         function(sql) {
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
      OhdsiRTools::stopCluster(cluster = cluster)
      
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
#' 
#' @export
createIndices <- function(connectionDetails,
                          resultsDatabaseSchema,
                          outputFolder,
                          sqlOnly = FALSE,
                          verboseMode = TRUE) {
  
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
  
  if (connectionDetails$dbms %in% c("redshift", "netezza")) {
    return (sprintf("/* INDEX CREATION SKIPPED, INDICES NOT SUPPORTED IN %s */", toupper(connectionDetails$dbms)))
  }
  
  if (connectionDetails$dbms == "pdw") {
    indicesSql <- c(indicesSql, 
                    SqlRender::renderSql("create clustered columnstore index ClusteredIndex_Achilles_results on @resultsDatabaseSchema.achilles_results;",
                                         resultsDatabaseSchema = resultsDatabaseSchema)$sql)
  }
  
  indices <- read.csv(file = system.file("csv", "post_processing", "indices.csv", package = "Achilles"), 
                      header = TRUE, stringsAsFactors = FALSE)
  
  # Check if concept_hierarchy table exists ------------------------------------------------------------------
  
  sql <- SqlRender::renderSql("select top 1 * from @resultsDatabaseSchema.concept_hierarchy;", 
                              resultsDatabaseSchema = resultsDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
  
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  conceptHierarchyTableExists <- tryCatch({
    DatabaseConnector::querySql(connection = connection, sql = sql)
    TRUE
  }, error = function(e) {
    FALSE
  })
  DatabaseConnector::disconnect(connection = connection)
  
  if (!conceptHierarchyTableExists) {
    indices <- indices[indices$TABLE_NAME != "concept_hierarchy",]
  }
  
  for (i in 1:nrow(indices)) {
    sql <- SqlRender::renderSql(sql = "drop index @resultsDatabaseSchema.@indexName;",
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                indexName = indices[i,]$INDEX_NAME)$sql
    sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    dropIndicesSql <- c(dropIndicesSql, sql)
    
    sql <- SqlRender::renderSql(sql = "create index @indexName on @resultsDatabaseSchema.@tableName (@fields);",
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                tableName = indices[i,]$TABLE_NAME,
                                indexName = indices[i,]$INDEX_NAME,
                                fields = paste(strsplit(x = indices[i,]$FIELDS, split = "~")[[1]], collapse = ","))$sql
    sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    indicesSql <- c(indicesSql, sql)
  }
  
  if (!sqlOnly) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    
    try(DatabaseConnector::executeSql(connection = connection, sql = paste(dropIndicesSql, collapse = "\n\n")), silent = TRUE)
    DatabaseConnector::executeSql(connection = connection, 
                                  sql = paste(indicesSql, collapse = "\n\n"))
    DatabaseConnector::disconnect(connection = connection)
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
    scratchDatabaseSchema <- "#"
    schemaDelim <- "s_"
  }  
  
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  
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
      sql <- SqlRender::renderSql("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@scratchTable;", 
                                  scratchDatabaseSchema = scratchDatabaseSchema,
                                  schemaDelim = schemaDelim,
                                  scratchTable = scratchTable)$sql
      sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    })
    
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
                                         connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                         tryCatch({
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)  
                                         }, error = function(e) {
                                           ParallelLogger::logError(sprintf("Drop Achilles Scratch Table -- ERROR (%s)", e))  
                                         }, finally = function(f) {
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
                                       })
    
    OhdsiRTools::stopCluster(cluster = cluster)
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
      sql <- SqlRender::renderSql("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@scratchTable;", 
                           scratchDatabaseSchema = scratchDatabaseSchema,
                           schemaDelim = schemaDelim,
                           scratchTable = scratchTable)$sql
      sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    })
    
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
                                         connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                         tryCatch({
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)  
                                         }, error = function(e) {
                                           ParallelLogger::logError(sprintf("Drop Heel Scratch Table -- ERROR (%s)", e))  
                                         }, finally = function(f) {
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
                                       })
    
    OhdsiRTools::stopCluster(cluster = cluster)
  }
  
  if ("concept_hierarchy" %in% tableTypes) {
    # Drop Concept Hierarchy Tables ------------------------------------------------------
    
    conceptHierarchyTables <- c("condition", "drug", "drug_era", "meas", "obs", "proc")
    
    dropSqls <- lapply(conceptHierarchyTables, function(scratchTable) {
      sql <- SqlRender::renderSql("IF OBJECT_ID('@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix@scratchTable', 'U') IS NOT NULL DROP TABLE @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix@scratchTable;", 
                           scratchDatabaseSchema = scratchDatabaseSchema,
                           schemaDelim = schemaDelim,
                           tempAchillesPrefix = tempAchillesPrefix,
                           scratchTable = scratchTable)$sql
      sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    })
    
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
                                         connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                         tryCatch({
                                           DatabaseConnector::executeSql(connection = connection, sql = sql)  
                                         }, error = function(e) {
                                           ParallelLogger::logError(sprintf("Drop Concept Hierarchy Scratch Table -- ERROR (%s)", e))  
                                         }, finally = function(f) {
                                           DatabaseConnector::disconnect(connection = connection)
                                         })
                                       })
    
    OhdsiRTools::stopCluster(cluster = cluster)
  }
  
  ParallelLogger::unregisterLogger("dropAllScratchTables")
}

.getCdmVersion <- function(connectionDetails, 
                           cdmDatabaseSchema) {
  sql <- SqlRender::renderSql(sql = "select cdm_version from @cdmDatabaseSchema.cdm_source",
                              cdmDatabaseSchema = cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
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
                                        outputFolder) {
  
  castedNames <- apply(resultsTable$schema, 1, function(field) {
    SqlRender::renderSql("cast(@fieldName as @fieldType) as @fieldName", 
                         fieldName = field["FIELD_NAME"],
                         fieldType = field["FIELD_TYPE"])$sql
  })
  
  detailSqls <- lapply(resultsTable$analysisIds[resultsTable$analysisIds %in% analysisIds], function(analysisId) { 
                  sql <- SqlRender::renderSql(sql = "select @castedNames from 
                                                    @scratchDatabaseSchema@schemaDelim@tablePrefix_@analysisId", 
                                                    scratchDatabaseSchema = scratchDatabaseSchema,
                                                    schemaDelim = schemaDelim,
                                                    castedNames = paste(castedNames, collapse = ", "), 
                                                    tablePrefix = resultsTable$tablePrefix, 
                                                    analysisId = analysisId)$sql
  
                  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
  })
  
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
  sql <- SqlRender::renderSql(sql = "select cdm_source_name from @cdmDatabaseSchema.cdm_source",
                              cdmDatabaseSchema = cdmDatabaseSchema)$sql
  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
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
    sql <- SqlRender::renderSql(sql = "delete from @resultsDatabaseSchema.achilles_results where analysis_id in (@analysisIds);",
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                analysisIds = paste(resultIds, collapse = ","))$sql  
    sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    DatabaseConnector::executeSql(connection = connection, sql = sql)
    DatabaseConnector::disconnect(connection = connection)
  }
  
  if (length(distIds) > 0) {
    sql <- SqlRender::renderSql(sql = "delete from @resultsDatabaseSchema.achilles_results_dist where analysis_id in (@analysisIds);",
                                resultsDatabaseSchema = resultsDatabaseSchema,
                                analysisIds = paste(distIds, collapse = ","))$sql
    sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    DatabaseConnector::executeSql(connection = connection, sql = sql)
    DatabaseConnector::disconnect(connection = connection)
  }
}
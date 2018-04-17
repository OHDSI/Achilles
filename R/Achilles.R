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
#     http://www.apache.org/licenses/LICENSE-2.0
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
#' @param conceptHierarchy                 Boolean to determine if the concept_hierarchy result table should be created, for use by Atlas treemaps. 
#'                                         Please note: this table creation only requires the Vocabulary, not the CDM itself. 
#'                                         You could run this once for 1 Vocab version, and then copy the table to all CDMs using that Vocab.
#' @param createIndices                    Boolean to determine if indices should be created on the resulting Achilles and concept_hierarchy table. Default= TRUE
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param dropScratchTables                (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place for later removal.
#' @param sqlOnly                          Boolean to determine if Achilles should be fully executed. TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     (OPTIONAL, SQL-only mode) Path to store SQL files
#' @param logMultiThreadPerformance        (OPTIONAL, multi-threaded mode) Should an RDS file of execution times for every analysis query be created in the outputFolder?
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
#'                                             numThreads = 10)
#'                                         }
#' @export
achilles <- function (connectionDetails, 
                      cdmDatabaseSchema,
                      oracleTempSchema = cdmDatabaseSchema,
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
                      conceptHierarchy = TRUE,
                      createIndices = TRUE,
                      numThreads = 1,
                      tempAchillesPrefix = "tmpach",
                      dropScratchTables = TRUE,
                      sqlOnly = FALSE,
                      outputFolder = "output",
                      logMultiThreadPerformance = FALSE) {
  
  achillesSql <- c()
  
  # Try to get CDM Version if not provided ----------------------------------------------------------------------------------------
  
  if (missing(cdmVersion)) {
    cdmVersion <- .getCdmVersion(connectionDetails, cdmDatabaseSchema)
  }
  
  # Check CDM version is valid ---------------------------------------------------------------------------------------------------
  
  if (compareVersion(a = as.character(cdmVersion), b = "5") < 0) {
    stop("Error: Invalid CDM Version number; this function is only for v5 and above. 
         See Achilles Git Repo to find v4 compatible version of Achilles.")
  }
  
  # Establish folder paths --------------------------------------------------------------------------------------------------------
  
  if (sqlOnly | logMultiThreadPerformance) {
    if (!dir.exists(outputFolder)) {
      dir.create(path = outputFolder, recursive = TRUE)
    }
    unlink(file.path(outputFolder, "achillesLog.rds"))
  }
  
  # (optional) Validate CDM schema --------------------------------------------------------------------------------------------------
  
  if (validateSchema) {
    validateSchema(connectionDetails = connectionDetails, 
                   cdmDatabaseSchema = cdmDatabaseSchema, 
                   resultsDatabaseSchema = resultsDatabaseSchema,
                   runCostAnalysis = runCostAnalysis, 
                   cdmVersion = cdmVersion)
  }
  
  # Get source name if none provided --------------------------------------------------
  
  if (missing(sourceName) & !sqlOnly) {
    sql <- SqlRender::renderSql(sql = "select top 1 cdm_source_name 
                                from @cdmDatabaseSchema.cdm_source",
                                cdmDatabaseSchema = cdmDatabaseSchema)$sql
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    sourceName <- tryCatch({
      s <- DatabaseConnector::querySql(connection = connection, sql = sql)
    }, error = function (e) {
      s <- ""
    }, finally = {
      DatabaseConnector::disconnect(connection = connection)
      rm(connection)
    })
  }
  
  # Obtain analyses to run --------------------------------------------------------------------------------------------------------
  
  analysisDetails <- getAnalysisDetails()
  if (!missing(analysisIds)) {
    analysisDetails <- analysisDetails[analysisDetails$ANALYSIS_ID %in% analysisIds, ]
  }
  
  if (!runCostAnalysis) {
    analysisDetails <- analysisDetails[analysisDetails$COST == 0, ]
  }
  
  resultsTables <- list(
    list(detailType = "results",
                  tablePrefix = tempAchillesPrefix, 
                  schema = read.csv(file = system.file("csv", "schema_achilles_results.csv", package = "Achilles"), 
                           header = TRUE),
                  analysisIds = analysisDetails[analysisDetails$DISTRIBUTION <= 0, ]$ANALYSIS_ID),
    list(detailType = "results_dist",
                      tablePrefix = sprintf("%1s_%2s", tempAchillesPrefix, "dist"),
                      schema = read.csv(file = system.file("csv", "schema_achilles_results_dist.csv", package = "Achilles"), 
                           header = TRUE),
                      analysisIds = analysisDetails[abs(analysisDetails$DISTRIBUTION) == 1, ]$ANALYSIS_ID))
  
  # Initialize thread and scratchDatabaseSchema settings ----------------------------------------------------------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1
    scratchDatabaseSchema <- "#"
    schemaDelim <- "s_"
    
    # first invocation of the connection, to persist throughout to maintain temp tables
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails) 
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
    costMappings <- read.csv(system.file("csv", "cost_columns.csv", package = "Achilles"), 
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
          DatabaseConnector::executeSql(connection = connection, sql = rawCostSql$sql)
        }
      } else {
        cluster <- OhdsiRTools::makeCluster(numberOfThreads = length(rawCostSqls), 
                                            singleThreadToMain = TRUE)
        results <- OhdsiRTools::clusterApply(cluster = cluster, 
                                           x = rawCostSqls, 
                                           function(rawCostSql) {
                                             start <- Sys.time()
                                             
                                             connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                             DatabaseConnector::executeSql(connection = connection, sql = rawCostSql$sql)
                                             DatabaseConnector::disconnect(connection = connection)
                                             
                                             df <- data.frame(
                                               queryName = "Raw Cost",
                                               queryId = rawCostSql$analysisId, 
                                               executionTime = Sys.time() - start
                                             )
                                           })
        .logMtPerformance(results, outputFolder)
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
          DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql$sql)
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
                                             
                                             connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                             DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql$sql)
                                             DatabaseConnector::disconnect(connection = connection)
                                             
                                             df <- data.frame(
                                               queryName = "Cost Analysis",
                                               queryId = distCostAnalysisSql$analysisId,
                                               executionTime = Sys.time() - start
                                             )
                                           })
        .logMtPerformance(results, outputFolder)
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
    writeLines(sprintf("Dropping scratch Achilles tables from schema %s", scratchDatabaseSchema))
    
    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads,
                         tableTypes = c("achilles"))
    
    writeLines(sprintf("Temporary Achilles tables removed from schema %s", scratchDatabaseSchema))
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
                               numThreads = numThreads)
    )
  })
  
  achillesSql <- c(achillesSql, lapply(mainSqls, function(s) s$sql))
    
  if (!sqlOnly) {
    writeLines("Executing multiple queries. This could take a while")
    
    if (numThreads == 1) {
      for (mainSql in mainSqls) {
        DatabaseConnector::executeSql(connection = connection, sql = mainSql$sql)
      }
    } else {
      cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
      results <- OhdsiRTools::clusterApply(cluster = cluster, 
                                         x = mainSqls, 
                                         function(mainSql) {
                                           start <- Sys.time()
                                           
                                           connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                           DatabaseConnector::executeSql(connection = connection, sql = mainSql$sql)
                                           DatabaseConnector::disconnect(connection = connection)
                                           
                                           df <- data.frame(
                                             queryName = "Main Analysis",
                                             queryId = mainSql$analysisId,
                                             executionTime = Sys.time() - start
                                           )
                                         })
      .logMtPerformance(results, outputFolder)
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
                               smallCellCount = smallCellcount)
  })
  
  achillesSql <- c(achillesSql, mergeSqls)

  if (!sqlOnly) {
    
    writeLines("Merging scratch Achilles tables")
    
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
    writeLines(sprintf("Done. Achilles results can now be found in schema %s", resultsDatabaseSchema))
  }
  
  # Clean up scratch tables -----------------------------------------------
  
  if (numThreads == 1) {
    # Dropping the connection removes the temporary scratch tables if running in serial
    DatabaseConnector::disconnect(connection = connection)
  } else if (dropScratchTables & !sqlOnly) {
    # Drop the scratch tables
    writeLines(sprintf("Dropping scratch Achilles tables from schema %s", scratchDatabaseSchema))
   
    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads,
                         tableTypes = c("achilles"))
    
    writeLines(sprintf("Temporary Achilles tables removed from schema %s", scratchDatabaseSchema))
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
                                           sqlOnly = sqlOnly)
  }
  achillesSql <- c(achillesSql, hierarchySql)

  
  # Create indices -----------------------------------------------------------------
  
  indicesSql <- "/* INDEX CREATION SKIPPED PER USER REQUEST */"
  
  if (createIndices) {
    indicesSql <- createIndices(connectionDetails,
                                resultsDatabaseSchema,
                                sqlOnly)    
  }
  achillesSql <- c(achillesSql, indicesSql)
  
  # Run Heel? ---------------------------------------------------------------
  
  heelSql <- "/* HEEL EXECUTION SKIPPED PER USER REQUEST */"
  if (runHeel) {
    heelSql <- achillesHeel(connectionDetails = connectionDetails,
                               cdmDatabaseSchema = cdmDatabaseSchema,
                               resultsDatabaseSchema = resultsDatabaseSchema,
                               scratchDatabaseSchema = scratchDatabaseSchema,
                               cdmVersion = cdmVersion,
                               sqlOnly = sqlOnly,
                               numThreads = numThreads,
                               tempHeelPrefix = "tmpheel",
                               dropScratchTables = dropScratchTables,
                               outputFolder = outputFolder)
    heelSql <- paste(heelSql, collapse = "\n\n")
  }
  
  achillesSql <- c(achillesSql, heelSql)
  
  achillesResults <- list(resultsConnectionDetails = connectionDetails,
                          resultsTable = "achilles_results",
                          resultsDistributionTable = "achilles_results_dist",
                          analysis_table = "achilles_analysis",
                          sourceName = sourceName,
                          analysisIds = analysisDetails$ANALYSIS_ID,
                          AchillesSql = paste(achillesSql, collapse = "\n\n"),
                          HeelSql = heelSql,
                          HierarchySql = hierarchySql,
                          IndicesSql = indicesSql,
                          call = match.call())
  
  class(achillesResults) <- "achillesResults"
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = paste(achillesSql, collapse = "\n\n"), targetFile = file.path(outputFolder, "achilles.sql"))
    writeLines(sprintf("All Achilles SQL scripts can be found in folder: %s", file.path(outputFolder, "achilles.sql")))
  }
  
  return (achillesResults)
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
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' 
#' @export
createConceptHierarchy <- function(connectionDetails, 
                                   resultsDatabaseSchema,
                                   scratchDatabaseSchema,
                                   vocabDatabaseSchema,
                                   numThreads = 1,
                                   tempAchillesPrefix = "tmpach",
                                   sqlOnly = FALSE) {
  
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
                                             scratchDatabaseSchema = scratchDatabaseSchema,
                                             vocabDatabaseSchema = vocabDatabaseSchema,
                                             schemaDelim = schemaDelim,
                                             tempAchillesPrefix = tempAchillesPrefix)
  })
  
  mergeSql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("post_processing", 
                                                                        "merge_concept_hierarchy.sql"),
                                                packageName = "Achilles",
                                                dbms = connectionDetails$dbms,
                                                resultsDatabaseSchema = resultsDatabaseSchema,
                                                scratchDatabaseSchema = scratchDatabaseSchema,
                                                schemaDelim = schemaDelim,
                                                tempAchillesPrefix = tempAchillesPrefix)

  
  if (!sqlOnly) {
    writeLines("Executing Concept Hierarchy creation. This could take a while")
  
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
    
    writeLines(sprintf("Done. Concept Hierarchy table can now be found in %s", resultsDatabaseSchema))  
  }

  return (c(hierarchySqls, mergeSql))
}


#' Create indicies
#' 
#' @details 
#' Post-processing, create indices to help performance. Cannot be used with Redshift.
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' 
#' @export
createIndices <- function(connectionDetails,
                          resultsDatabaseSchema,
                          sqlOnly = FALSE) {
  
  if (connectionDetails$dbms %in% c("redshift")) {
    return <- "/* INDEX CREATION SKIPPED, INDICES NOT SUPPORTED IN REDSHIFT */"
  }
  indicesSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "post_processing/achilles_indices.sql",
                                                  packageName = "Achilles",
                                                  dbms = connectionDetails$dbms,
                                                  resultsDatabaseSchema = resultsDatabaseSchema)
    
  if (!sqlOnly) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    DatabaseConnector::executeSql(connection = connection, sql = indicesSql)
    DatabaseConnector::disconnect(connection = connection)
  }
  
  return (indicesSql)
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
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' 
#' @export
validateSchema <- function(connectionDetails,
                           cdmDatabaseSchema,
                           resultsDatabaseSchema = cdmDatabaseSchema,
                           cdmVersion,
                           runCostAnalysis,
                           sqlOnly = FALSE) {

  outputFolder <- "output"
  
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
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           runCostAnalysis = runCostAnalysis,
                                           cdmVersion = cdmVersion)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "ValidateSchema.sql")) 
  } else {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    tables <- DatabaseConnector::querySql(connection = connection, sql = sql)
    writeLines("CDM Schema is valid")
    DatabaseConnector::disconnect(connection = connection)
  }
  
  return (sql)
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
  pathToCsv <- system.file("csv", "analysisDetails.csv", package = "Achilles")
  analysisDetails <- read.csv(file = pathToCsv, header = TRUE, stringsAsFactors = FALSE)
  return (analysisDetails)
}

#' Drop all possible scratch tables
#' 
#' @details 
#' Drop all possible Achilles and Heel scratch tables
#' 
#' @param connectionDetails                An R object of type \code{connectionDetails} created using the function \code{createConnectionDetails} in the \code{DatabaseConnector} package.
#' @param scratchDatabaseSchema            string name of database schema that Achilles scratch tables were written to. 
#' @param tempAchillesPrefix               The prefix to use for the "temporary" (but actually permanent) Achilles analyses tables. Default is "tmpach"
#' @param tempHeelPrefix                   The prefix to use for the "temporary" (but actually permanent) Heel tables. Default is "tmpheel"
#' @param numThreads                       The number of threads to use to run this function. Default is 1 thread.
#' @param tableTypes                       The types of Achilles scratch tables to drop: achilles or heel or both
#' 
#' @export
dropAllScratchTables <- function(connectionDetails, 
                                 scratchDatabaseSchema, 
                                 tempAchillesPrefix = "tmpach", 
                                 tempHeelPrefix = "tmpheel", 
                                 numThreads = 1,
                                 tableTypes = c("achilles", "heel")) {
  
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  
  scratchTables <- lapply(DatabaseConnector::getTableNames(connection = connection, 
                                                    databaseSchema = scratchDatabaseSchema), function(t) tolower(t))
  
  if ("achilles" %in% tableTypes) {
  
    # Drop Achilles Scratch Tables ------------------------------------------------------
    
    analysisDetails <- getAnalysisDetails()
    
    resultsTables <- lapply(analysisDetails$ANALYSIS_ID[analysisDetails$DISTRIBUTION <= 0], function(id) {
      sprintf("%s_%d", tempAchillesPrefix, id)
    })
    
    resultsDistTables <- lapply(analysisDetails$ANALYSIS_ID[abs(analysisDetails$DISTRIBUTION) == 1], function(id) {
      sprintf("%s_dist_%d", tempAchillesPrefix, id)
    })
    
    dropTables <- c(Reduce(intersect, list(scratchTables, resultsTables)), 
                    Reduce(intersect, list(scratchTables, resultsDistTables)))
    
    dropSqls <- lapply(dropTables, function(scratchTable) {
      SqlRender::renderSql("drop table @scratchDatabaseSchema.@scratchTable;", 
                           scratchDatabaseSchema = scratchDatabaseSchema,
                           scratchTable = scratchTable)$sql
    })
    
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
                                         connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                         DatabaseConnector::executeSql(connection = connection, sql = sql)
                                         DatabaseConnector::disconnect(connection = connection)
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
    
    dropTables <- Reduce(intersect, list(scratchTables, parallelHeelTables))
  
    dropSqls <- lapply(dropTables, function(scratchTable) {
      SqlRender::renderSql("drop table @scratchDatabaseSchema.@scratchTable;", 
                           scratchDatabaseSchema = scratchDatabaseSchema,
                           scratchTable = scratchTable)$sql
    })
    
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                       x = dropSqls, 
                                       function(sql) {
                                         connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
                                         DatabaseConnector::executeSql(connection = connection, sql = sql)
                                         DatabaseConnector::disconnect(connection = connection)
                                       })
    
    OhdsiRTools::stopCluster(cluster = cluster)
  }
}

.getCdmVersion <- function(connectionDetails, cdmDatabaseSchema) {
  sql <- SqlRender::renderSql(sql = "select top 1 cdm_version 
                                from @cdmDatabaseSchema.cdm_source",
                              cdmDatabaseSchema = cdmDatabaseSchema)$sql
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  cdmVersion <- tryCatch({
    c <- DatabaseConnector::querySql(connection = connection, sql = sql)
  }, error = function (e) {
    c <- ""
  }, finally = {
    DatabaseConnector::disconnect(connection = connection)
    connection <- NULL
  })
  
  return (c)
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
                                   numThreads) {
  outputFolder <- "output"
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("analyses", paste(analysisId, "sql", sep = ".")),
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           schemaDelim = schemaDelim,
                                           tempAchillesPrefix = tempAchillesPrefix,
                                           source_name = sourceName,
                                           achilles_version = packageVersion(pkg = "Achilles"),
                                           cdmVersion = cdmVersion,
                                           singleThreaded = (scratchDatabaseSchema == "#"))
  
  return (sql)
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
                                        smallCellCount) {
  outputFolder <- "output"
  
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
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/merge_achilles_tables.sql",
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           createTable = createTable,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           detailType = resultsTable$detailType,
                                           detailSqls = paste(detailSqls, collapse = " \nunion all\n "),
                                           fieldNames = paste(resultsTable$schema$FIELD_NAME, collapse = ", "),
                                           smallCellCount = smallCellcount)
  
  return (sql)
}

.logMtPerformance <- function(results, outputFolder) {
  newDf <- do.call("rbind", results)
  logFile <- file.path(outputFolder, "achillesLog.rds")
  if (file.exists(logFile)) {
    oldDf <- readRDS(logFile)
    newDf <- rbind(oldDf, newDf)
  }
  
  saveRDS(object = newDf, file = logFile)
}

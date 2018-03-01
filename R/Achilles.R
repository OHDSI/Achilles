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


#' The main Achilles analysis (for v5.x)
#'
#' @description
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#'
#' @details
#' \code{achilles} creates descriptive statistics summary for an entire OMOP CDM instance.
#' 
#' @param connectionDetails                An R object of type ConnectionDetails (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmDatabaseSchema    	           Fully qualified name of database schema that contains OMOP CDM (including Vocabulary). 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         Fully qualified name of database schema that we can write final results to. Default is cdmDatabaseSchema. 
#'                                         On SQL Server, this should specifiy both the database and the schema, so for example, on SQL Server, 'cdm_results.dbo'.
#' @param scratchDatabaseSchema            Fully qualified name of the database schema that will store all of the intermediate scratch tables, so for example, on SQL Server, 'cdm_scratch.dbo'. 
#'                                         Must be accessible to/from the cdmDatabaseSchema and the resultsDatabaseSchema. Default is resultsDatabaseSchema. 
#'                                         Making this "#" will run Achilles in single-threaded mode and use temporary tables instead of permanent tables.
#' @param vocabDatabaseSchema		           String name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param sourceName		                   String name of the database, as recorded in results.
#' @param analysisIds		                   (OPTIONAL) A vector containing the set of Achilles analysisIds for which results will be generated. 
#'                                         If not specified, all analyses will be executed. Use \code{\link{getAnalysisDetails}} to get a list of all Achilles analyses and their Ids.
#' @param createTable                      If true, new results tables will be created in the results schema. If not, the tables are assumed to already exist, and analysis results will be inserted (slower on MPP).
#' @param smallcellcount                   To avoid patient identifiability, cells with small counts (<= smallcellcount) are deleted. Set to NULL if you don't want any deletions.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above.  Default = "5". v4 support is in \code{\link{achilles_v4}}.
#' @param runHeel                          Boolean to determine if Achilles Heel data quality reporting will be produced based on the summary statistics.  Default = TRUE
#' @param validateSchema                   Boolean to determine if CDM Schema Validation should be run. This could be very slow.  Default = FALSE
#' @param runCostAnalysis                  Boolean to determine if cost analysis should be run. Note: only works on v5.1+ style cost tables.
#' @param conceptHierarchy                 Boolean to determine if the concept_hierarchy result table should be created, for use by Atlas treemaps. Note: only works on CDM v5.0 tables.
#' @param createIndices                    Boolean to determine if indices should be created on the resulting Achilles and concept_hierarchy table. Default= TRUE
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempAchillesPrefix               (OPTIONAL, multi-threaded mode) The prefix to use for the scratch Achilles analyses tables. Default is "tmpach"
#' @param dropScratchTables                (OPTIONAL, multi-threaded mode) TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place for later removal.
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     (OPTIONAL, sql only mode) Path to store SQL files
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
                      smallcellcount = 5, 
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
                      outputFolder = "output") {
  
  if (compareVersion(a = cdmVersion, b = "5") < 0) {
    stop("Error: Invalid CDM Version number; this function is only for v5 and above. 
         See Achilles Git Repo to find v4 compatible version of Achilles.")
  }
  
  # Establish folder paths --------------------------------------------------------------------------------------------------------
  
  if (sqlOnly) {
    unlink(x = outputFolder, recursive = TRUE, force = TRUE)
    dir.create(path = outputFolder, recursive = TRUE)
  }
  
  # Validate CDM schema (optional) --------------------------------------------------------------------------------------------------
  
  if (validateSchema) {
    validateSchema(connectionDetails = connectionDetails, 
                   cdmDatabaseSchema = cdmDatabaseSchema, 
                   runCostAnalysis = runCostAnalysis, 
                   cdmVersion = cdmVersion)
  }
  
  # Get source name if none provided --------------------------------------------------
  
  if (is.null(sourceName)) {
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
      connection <- NULL
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
  
  detailTables <- list(
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
  
  # Initialize serial execution (use temp tables and 1 thread only) ----------------------------------------------------------------
  
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
    
    if (sqlOnly) {
      SqlRender::writeSql(sql = sql, 
                          targetFile = file.path(outputFolder, "CreateAnalysisTable.sql"))
    } else {
      if (numThreads == 1) { 
        # connection is already alive
        DatabaseConnector::executeSql(connection = connection, sql = sql)
      } else {
        connection <- DatabaseConnector::connect(connectionDetails)
        DatabaseConnector::executeSql(connection = connection, sql = sql)
        DatabaseConnector::disconnect(connection)
      }
    }
  }
  
  # Clean up earlier scratch tables -------------------------------------------------
  
  if (numThreads > 1 && !sqlOnly) {
    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads)
  }
  
  # Generate cost analyses ----------------------------------------------------------
  
  if (runCostAnalysis) {
    distCostAnalysisDetails <- analysisDetails[analysisDetails$COST == 1 & analysisDetails$DISTRIBUTION == 1, ]
    analysisDetails <- dplyr::anti_join(x = analysisDetails, y = distCostAnalysisDetails, by = "ANALYSIS_ID")
 
    costMappings <- read.csv(system.file("csv", "cost_columns.csv", package = "Achilles"), 
                             header = TRUE, stringsAsFactors = FALSE)
    
    drugCostMappings <- costMappings[costMappings$DOMAIN == "Drug", ]
    procedureCostMappings <- costMappings[costMappings$DOMAIN == "Procedure", ]
    
    distCostDrugSqls <- 
      apply(distCostAnalysisDetails[distCostAnalysisDetails$STRATUM_1_NAME == "drug_concept_id", ], 1, 
            function (analysisDetail) {
              sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/cost_distribution_template.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       cdmVersion = cdmVersion,
                                                       schemaDelim = schemaDelim,
                                                       cdmDatabaseSchema = cdmDatabaseSchema,
                                                       scratchDatabaseSchema = scratchDatabaseSchema,
                                                       costColumn = drugCostMappings[drugCostMappings$OLD == analysisDetail["DISTRIBUTED_FIELD"][[1]], ]$CURRENT,
                                                       countValue = analysisDetail["DISTRIBUTED_FIELD"][[1]],
                                                       domain = "Drug",
                                                       domainTable = "drug_exposure", 
                                                       analysisId = analysisDetail["ANALYSIS_ID"][[1]],
                                                       tempAchillesPrefix = tempAchillesPrefix)
              })
    
    distCostProcedureSqls <- 
      apply(distCostAnalysisDetails[distCostAnalysisDetails$STRATUM_1_NAME == "procedure_concept_id", ], 1,
            function (analysisDetail) {
              sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/cost_distribution_template.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       cdmVersion = cdmVersion,
                                                       schemaDelim = schemaDelim,
                                                       cdmDatabaseSchema = cdmDatabaseSchema,
                                                       scratchDatabaseSchema = scratchDatabaseSchema,
                                                       costColumn = procedureCostMappings[drugCostMappings$OLD == analysisDetail["DISTRIBUTED_FIELD"][[1]], ]$CURRENT,
                                                       countValue = analysisDetail["DISTRIBUTED_FIELD"],
                                                       domain = "Procedure",
                                                       domainTable = "procedure_occurrence", 
                                                       analysisId = analysisDetail["ANALYSIS_ID"],
                                                       tempAchillesPrefix = tempAchillesPrefix)
              })
    
    if (sqlOnly) {
      SqlRender::writeSql(sql = paste(distCostDrugSqls, distCostProcedureSqls, sep = "\n\n"), 
                          targetFile = file.path(outputFolder, "DistributedCosts.sql"))
    } else {
        distCostAnalysisSqls <- c(distCostDrugSqls, distCostProcedureSqls)
        cluster <- OhdsiRTools::makeCluster(numberOfThreads = ifelse(numThreads > 1, length(distCostAnalysisDetails), 1), 
                                            singleThreadToMain = TRUE)
        dummy <- OhdsiRTools::clusterApply(cluster = cluster, 
                                           x = distCostAnalysisSqls, 
                                           function(distCostAnalysisSql) {
                                             if (numThreads > 1) {
                                               connection <- DatabaseConnector::connect(connectionDetails)
                                               }
                                             DatabaseConnector::executeSql(connection = connection, sql = distCostAnalysisSql)
                                             if (numThreads > 1) {
                                               DatabaseConnector::disconnect(connection)
                                               }
                                             })
        OhdsiRTools::stopCluster(cluster)
    }
  }
  
  # Generating Main Analyses ----------------------------------------------------------------------------------------------------------------
  
  if (sqlOnly) {
    writeLines("Achilles SQL scripts generating")
  } else {
    writeLines("Executing multiple queries. This could take a while")
  }
  
  cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
  dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = analysisDetails$ANALYSIS_ID, 
                                     fun = .runAchillesAnalysisId,
                                     connectionDetails = connectionDetails,
                                     connection = connection,
                                     schemaDelim = schemaDelim,
                                     scratchDatabaseSchema = scratchDatabaseSchema,
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     cdmVersion = cdmVersion,
                                     tempAchillesPrefix = tempAchillesPrefix,
                                     detailTables = detailTables,
                                     sourceName = sourceName,
                                     numThreads = numThreads,
                                     sqlOnly = sqlOnly)
  OhdsiRTools::stopCluster(cluster)
  
  cluster <- OhdsiRTools::makeCluster(numberOfThreads = ifelse(numThreads > 1, 2, 1), singleThreadToMain = TRUE)
  dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = detailTables, fun = .mergeAchillesScratchTables,
                                     connectionDetails = connectionDetails,
                                     connection = connection,
                                     createTable = createTable,
                                     schemaDelim = schemaDelim,
                                     scratchDatabaseSchema = scratchDatabaseSchema,
                                     resultsDatabaseSchema = resultsDatabaseSchema,
                                     cdmVersion = cdmVersion,
                                     tempAchillesPrefix = tempAchillesPrefix,
                                     numThreads = numThreads,
                                     sqlOnly = sqlOnly,
                                     smallcellcount = smallcellcount)
  
  OhdsiRTools::stopCluster(cluster)  

  if (sqlOnly) {
    writeLines(paste0("All Achilles SQL scripts can be found in folder: ", outputFolder))
  } else {
    writeLines(paste0("Done. Achilles results can now be found in schema ", resultsDatabaseSchema))
  }
  
  # Create concept hierarchy table -----------------------------------------------------------------
  
  if (conceptHierarchy) {
    hierarchySql <- SqlRender::loadRenderTranslateSql(sqlFilename = "post_processing/concept_hierarchy.sql",
                                                      packageName = "Achilles",
                                                      dbms = connectionDetails$dbms,
                                                      oracleTempSchema = oracleTempSchema,
                                                      results_database_schema = resultsDatabaseSchema,
                                                      vocab_database_schema = vocabDatabaseSchema
    )
    
    if (sqlOnly) {
      SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "CreateConceptHierarchy.sql"))
    } else {
      writeLines("Executing Concept Hierarchy creation. This could take a while")
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      DatabaseConnector::executeSql(connection = connection, sql = hierarchySql)
      DatabaseConnector::disconnect(connection = connection)
      writeLines(paste0("Done. Concept Hierarchy table can now be found in ", resultsDatabaseSchema))  
    }
  } 
  
  # Create indices -----------------------------------------------------------------
  
  if (createIndices && 
      connectionDetails$dbms != "redshift" &&
      connectionDetails$dbms != "netezza") {
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "post_processing/achilles_indices.sql",
                                             packageName = "Achilles",
                                             dbms = connectionDetails$dbms,
                                             resultsDatabaseSchema = resultsDatabaseSchema)
    
    if (sqlOnly) {
      SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "CreateIndices.sql"))
    }
    else {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      DatabaseConnector::executeSql(connection = connection, sql = sql)
      DatabaseConnector::disconnect(connection = connection)
    }
  }
  
  # Drop scratch tables -----------------------------------------------
  
  if (numThreads == 1) {
    # Dropping the connection removes the temporary scratch tables if running in serial
    DatabaseConnector::disconnect(connection = connection)
  } else if (dropScratchTables) {
    # Drop the scratch tables
    writeLines(paste0("Dropping scratch Achilles tables from schema ", scratchDatabaseSchema))
    
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = analysisDetails$ANALYSIS_ID,
                                       fun = .dropAchillesScratchTable,
                                       connectionDetails = connectionDetails,
                                       scratchDatabaseSchema = scratchDatabaseSchema,
                                       tempAchillesPrefix = tempAchillesPrefix,
                                       detailTables = detailTables,
                                       sqlOnly = sqlOnly)
    
    OhdsiRTools::stopCluster(cluster = cluster)
    writeLines(paste0("Temporary Achilles tables removed from schema ", scratchDatabaseSchema))
  }
  
  # Run Heel? ---------------------------------------------------------------
  
  if (runHeel) {
    achillesHeel(connectionDetails = connectionDetails,
                 cdmDatabaseSchema = cdmDatabaseSchema,
                 resultsDatabaseSchema = resultsDatabaseSchema,
                 scratchDatabaseSchema = scratchDatabaseSchema,
                 cdmVersion = cdmVersion,
                 sqlOnly = sqlOnly,
                 numThreads = numThreads,
                 tempHeelPrefix = "tmpheel",
                 dropScratchTables = dropScratchTables,
                 outputFolder = outputFolder)
  }
}


#' Execution of data quality rules (for v5 and above)
#'
#' @description
#' \code{achillesHeel} executes data quality rules (or checks) on pre-computed analyses (or measures).
#'
#' @details
#' \code{achillesHeel} contains number of rules (authored in SQL) that are executed against achilles results tables.
#' 
#' @param connectionDetails                An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmDatabaseSchema    	           string name of database schema that contains OMOP CDM. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.
#' @param resultsDatabaseSchema		         string name of database schema that we can write final results to. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, 
#'                                         so for example 'results.dbo'.
#' @param scratchDatabaseSchema            (OPTIONAL, multi-threaded mode) Name of a fully qualified schema that is accessible to/from the resultsDatabaseSchema, that can store all of the scratch tables. Default is resultsDatabaseSchema.
#' @param cdmVersion                       Define the OMOP CDM version used:  currently supports v5 and above.  Default = "5". 
#' @param numThreads                       (OPTIONAL, multi-threaded mode) The number of threads to use to run Achilles in parallel. Default is 1 thread.
#' @param tempHeelPrefix                   (OPTIONAL, multi-threaded mode) The prefix to use for the "temporary" (but actually permanent) Heel tables. Default is "tmpheel"
#' @param dropScratchTables                In multi-threaded mode: TRUE = drop the scratch tables (may take time depending on dbms), FALSE = leave them in place
#' @param ThresholdAgeWarning              The maximum age to allow in Heel
#' @param ThresholdOutpatientVisitPerc     The maximum percentage of outpatient visits among all visits
#' @param ThresholdMinimalPtMeasDxRx       The minimum percentage of patients with at least 1 Measurement, 1 Dx, and 1 Rx
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' @param outputFolder                     (OPTIONAL, sql only mode) Path to store SQL files
#' 
#' @return nothing is returned
#' @examples \dontrun{
#'   connectionDetails <- createConnectionDetails(dbms="sql server", server="some_server")
#'   achillesHeel <- achillesHeel(connectionDetails = connectionDetails, 
#'                                cdmDatabaseSchema = "cdm", 
#'                                resultsDatabaseSchema = "results", 
#'                                scratchDatabaseSchema = "scratch",
#'                                cdmVersion = "5.3.0",
#'                                numThreads = 10)
#' }
#' @export
achillesHeel <- function(connectionDetails, 
                         cdmDatabaseSchema, 
                         resultsDatabaseSchema = cdmDatabaseSchema,
                         scratchDatabaseSchema = resultsDatabaseSchema,
                         cdmVersion = "5",
                         numThreads = 1,
                         tempHeelPrefix = "tmpheel",
                         dropScratchTables = FALSE,
                         ThresholdAgeWarning = 125,
                         ThresholdOutpatientVisitPerc = 0.43,
                         ThresholdMinimalPtMeasDxRx = 20.5,
                         outputFolder = "output",
                         sqlOnly = FALSE) {
  
  if (compareVersion(a = cdmVersion, b = "5") < 0) {
    stop("Error: Invalid CDM Version number; this function is only for v5 and above. 
         See Achilles Git Repo to find v4 compatible version of Achilles.")
  }
  
  if (sqlOnly) {
    unlink(x = outputFolder, recursive = TRUE, force = TRUE)
    dir.create(path = outputFolder, recursive = TRUE)
  }
  
  # Initialize serial execution (use temp tables and 1 thread only) ----------------------------------------------------------------
  
  schemaDelim <- "."
  
  if (numThreads == 1 || scratchDatabaseSchema == "#") {
    numThreads <- 1
    scratchDatabaseSchema <- "#"
    schemaDelim <- "s_"
    connection <- DatabaseConnector::connect(connectionDetails) 
    # first invocation of the connection, to persist throughout to maintain temp tables
  }
  
  # Clean up earlier scratch tables -------------------------------------------------
  
  if (numThreads > 1 && !sqlOnly) {
    dropAllScratchTables(connectionDetails = connectionDetails, 
                         scratchDatabaseSchema = scratchDatabaseSchema, 
                         tempAchillesPrefix = tempAchillesPrefix, 
                         numThreads = numThreads)
  }
  
  # Sub-functions to handle cluster applied operations----------------------------------------------------------------------------------
  
  writeLines("Executing Achilles Heel. This could take a while")
  
  heelFiles <- list.files(path = paste(system.file(package = 'Achilles'), 
                                       "sql/sql_server", inputFolder, "independents", sep = "/"), 
                          recursive = TRUE, 
                          full.names = TRUE, 
                          all.files = FALSE,
                          pattern = "\\.sql$")
  
  
  # Generate parallel Heels --------------------------------------------------------
  
  if (numThreads > 1) {
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = heelFiles,
                                       fun = .dropHeelScratchTable,
                                       connectionDetails = connectionDetails, 
                                       scratchDatabaseSchema = scratchDatabaseSchema,
                                       tempHeelPrefix = tempHeelPrefix, 
                                       sqlOnly = sqlOnly)
    OhdsiRTools::stopCluster(cluster)     
  }

  cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
  dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = heelFiles,
                                     fun = .runHeelId,
                                     connectionDetails = connectionDetails,
                                     connection = ifelse(numThreads == 1, connection, NULL),
                                     cdmDatabaseSchema = cdmDatabaseSchema,
                                     resultsDatabaseSchema = resultsDatabaseSchema,
                                     scratchDatabaseSchema = scratchDatabaseSchema,
                                     schemaDelim = schemaDelim,
                                     tempHeelPrefix = tempHeelPrefix,
                                     numThreads = numThreads,
                                     sqlOnly = sqlOnly,
                                     inputFolder = inputFolder,
                                     outputFolder = outputFolder)
  OhdsiRTools::stopCluster(cluster)
  
  
  # Merge scratch Heel tables into final tables ----------------------------------------
  
  isDerived <- sapply(heelFiles, function(heelFile) { grepl(pattern = "derived", heelFile) })
  
  derivedSqls <- lapply(heelFiles[isDerived], function(heelFile) {
    SqlRender::renderSql(sql = 
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
                         heelName = gsub(pattern = ".sql", replacement = "", x = basename(heelFile)))$sql   
  })
  
  derivedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "heels/merge_derived.sql", 
                                                  packageName = "Achilles", 
                                                  dbms = connectionDetails$dbms,
                                                  resultsDatabaseSchema = resultsDatabaseSchema,
                                                  derivedSqls = paste(derivedSqls, collapse = " \nunion all\n "))
  
  resultSqls <- lapply(X = heelFiles[!isDerived], function(heelFile) {
    SqlRender::renderSql(sql = 
                "select 
              cast(analysis_id as int) as analysis_id, 
              cast(ACHILLES_HEEL_warning as varchar(255)) as ACHILLES_HEEL_warning, 
              cast(rule_id as int) as rule_id, 
              cast(record_count as bigint) as record_count
              from @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName",
              scratchDatabaseSchema = scratchDatabaseSchema,
              schemaDelim = ifelse(scratchDatabaseSchema == "#", "s_", "."),
              tempHeelPrefix = tempHeelPrefix,
              heelName = gsub(pattern = ".sql", replacement = "", x = basename(heelFile)))$sql   
  })
  
  resultSql <- SqlRender::loadRenderTranslateSql(sqlFilename = paste(inputFolder, "merge_heel_results.sql", sep = "/"), 
                                                 packageName = "Achilles", 
                                                 dbms = connectionDetails$dbms,
                                                 resultsDatabaseSchema = resultsDatabaseSchema,
                                                 resultSqls = paste(resultSqls, collapse = " \nunion all\n "))
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = derivedSql, targetFile = paste(outputFolder, "merge_derived.sql", sep = "/"))
    SqlRender::writeSql(sql = resultSql, targetFile = paste(outputFolder, "merge_heel_results.sql", sep = "/"))
  } else {
    cluster <- OhdsiRTools::makeCluster(numberOfThreads = ifelse(numThreads > 1, 2, 1), singleThreadToMain = TRUE)
    dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = c(derivedSql, resultSql), 
                                       function(sql) {
                                         if (numThreads > 1) {
                                           connection <- DatabaseConnector::connect(connectionDetails)
                                         }
                                         DatabaseConnector::executeSql(connection = connection, sql = sql)
                                         if (numThreads > 1) {
                                           DatabaseConnector::disconnect(connection)
                                         }
                                       }
    )
    OhdsiRTools::stopCluster(cluster)
  }
  
  # Run serial queries to finish up ---------------------------------------------------
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "heels/dependents.sql",
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           ThresholdAgeWarning = ThresholdAgeWarning,
                                           ThresholdOutpatientVisitPerc = ThresholdOutpatientVisitPerc,
                                           ThresholdMinimalPtMeasDxRx = ThresholdMinimalPtMeasDxRx
  )
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "Serial.sql"))
  } else {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    DatabaseConnector::executeSql(connection = connection, sql = sql)
    DatabaseConnector::disconnect(connection = connection)
  }
  
  # Drop scratch tables -----------------------------------------------
  
  if (numThreads == 1) {
    # Dropping the connection removes the temporary scratch tables if running in serial
    DatabaseConnector::disconnect(connection)
  } else {
    if (dropScratchTables) {
      cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads)
      dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = heelFiles, 
                                         fun = .dropHeelScratchTable,
                                         connectionDetails = connectionDetails,
                                         resultsDatabaseSchema = resultsDatabaseSchema,
                                         tempHeelPrefix = tempHeelPrefix,
                                         sqlOnly = sqlOnly)
      
      OhdsiRTools::stopCluster(cluster)  
    }
  }
  writeLines(paste("Done. Achilles Heel results can now be found in", resultsDatabaseSchema))
}



#' Validate the CDM schema
#' 
#' @details 
#' Runs a validation script to ensure the CDM is valid based on v5.x
#' 
#' @param connectionDetails                An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmDatabaseSchema    	           string name of database schema that contains OMOP CDM. On SQL Server, this should specifiy both the database and the schema, so for example 'cdm_instance.dbo'.
#' @param runCostAnalysis                  Boolean to determine if cost analysis should be run. Note: only works on CDM v5 and v5.1.0+ style cost tables.
#' @param sqlOnly                          TRUE = just generate SQL files, don't actually run, FALSE = run Achilles
#' 
#' @export
validateSchema <- function(connectionDetails,
                           cdmDatabaseSchema,
                           runCostAnalysis,
                           sqlOnly = FALSE) {

  outputFolder <- "output"
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "validate_schema.sql", 
                                           packageName = "Achilles", 
                                           dbms = connectionDetails$dbms,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           runCostAnalysis = runCostAnalysis,
                                           cdmVersion = cdmVersion)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = file.path(outputFolder, "ValidateSchema.sql")) 
  } else {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    tables <- DatabaseConnector::querySql(connection = connection, sql = sql)
    writeLines(paste("CDM Schema is valid:", paste(unlist(tables), collapse = ", "), sep = "\n\n"))
    DatabaseConnector::disconnect(connection = connection)
  }
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
getAnalysisDetails <- function()
{
  pathToCsv <- system.file("csv", "analysisDetails.csv", package = "Achilles")
  analysisDetails <- read.csv(file = pathToCsv, header = TRUE, stringsAsFactors = FALSE)
  return(analysisDetails)
}


#' Drop all the scratch tables
#' 
#' @details 
#' Drop all possible Achilles and Heel scratch tables
#' 
#' @param connectionDetails                An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param scratchDatabaseSchema            string name of database schema that Achilles scratch tables were written to. 
#' @param tempAchillesPrefix               The prefix to use for the "temporary" (but actually permanent) Achilles analyses tables. Default is "tmpach"
#' @param tempHeelPrefix                   The prefix to use for the "temporary" (but actually permanent) Heel tables. Default is "tmpheel"
#' @param numThreads                       The number of threads to use to run this function. Default is 1 thread.
#' 
#' 
#' @export
dropAllScratchTables <- function(connectionDetails, 
                                 scratchDatabaseSchema, 
                                 tempAchillesPrefix = "tmpach", 
                                 tempHeelPrefix = "tmpheel", 
                                 numThreads = 1) {
  # Drop Achilles Scratch Tables ------------------------------------------------------
  
  analysisDetails <- getAnalysisDetails()
  detailTables <- list(
    list(detailType = "results",
         tablePrefix = tempAchillesPrefix, 
         schema = read.csv(file = system.file("csv", "schema_achilles_results.csv", package = "Achilles"), 
                           header = TRUE, stringsAsFactors = FALSE),
         analysisIds = analysisDetails[analysisDetails$DISTRIBUTION <= 0, ]$ANALYSIS_ID),
    list(detailType = "results_dist",
         tablePrefix = sprintf("%1s_%2s", tempAchillesPrefix, "dist"),
         schema = read.csv(file = system.file("csv", "schema_achilles_results_dist.csv", package = "Achilles"), 
                           header = TRUE, stringsAsFactors = FALSE),
         analysisIds = analysisDetails[analysisDetails$DISTRIBUTION == 1, ]$ANALYSIS_ID))
  
  cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
  dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = analysisDetails$ANALYSIS_ID, 
                                     fun = .dropAchillesScratchTable,
                                     connectionDetails = connectionDetails,
                                     scratchDatabaseSchema = scratchDatabaseSchema,
                                     tempAchillesPrefix = tempAchillesPrefix,
                                     detailTables = detailTables,
                                     sqlOnly = FALSE)
  
  OhdsiRTools::stopCluster(cluster)
  
  # Drop Heel Scratch Tables ------------------------------------------------------
  
  heelFiles <- list.files(path = file.path(system.file(package = "Achilles"), 
                                       "sql/sql_server/heels/independents"), 
                          recursive = TRUE, 
                          full.names = TRUE, 
                          all.files = FALSE,
                          pattern = "\\.sql$")
  
  cluster <- OhdsiRTools::makeCluster(numberOfThreads = numThreads, singleThreadToMain = TRUE)
  
  dummy <- OhdsiRTools::clusterApply(cluster = cluster, x = heelFiles, 
                                     fun = .dropHeelScratchTable,
                                     connectionDetails = connectionDetails,
                                     scratchDatabaseSchema = scratchDatabaseSchema,
                                     tempHeelPrefix = tempHeelPrefix,
                                     sqlOnly = FALSE)
  
  OhdsiRTools::stopCluster(cluster)
}


.dropAchillesScratchTable <- function(analysisId,
                                      connectionDetails, 
                                      scratchDatabaseSchema, 
                                      tempAchillesPrefix, 
                                      detailTables,
                                      sqlOnly = FALSE) {
  for (detailTable in detailTables) {
    if (analysisId %in% detailTable$analysisIds) {
      sql <- SqlRender::renderSql(sql = "IF OBJECT_ID('@scratchDatabaseSchema.@tablePrefix_@analysisId', 'U') IS NOT NULL 
                                  DROP TABLE @scratchDatabaseSchema.@tablePrefix_@analysisId;",
                                  tablePrefix = detailTable$tablePrefix,
                                  scratchDatabaseSchema = scratchDatabaseSchema, 
                                  analysisId = analysisId)$sql
      sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
      
      if (!sqlOnly) {
        connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
        DatabaseConnector::executeSql(connection = connection, sql = sql)
        DatabaseConnector::disconnect(connection = connection)
      }
    }
  }
}

.dropHeelScratchTable <- function(heelFile,
                                  connectionDetails, 
                                  scratchDatabaseSchema, 
                                  tempHeelPrefix, 
                                  sqlOnly = FALSE) {
  
  sql <- SqlRender::renderSql(sql = "IF OBJECT_ID('@scratchDatabaseSchema.@tempHeelPrefix_@heelName', 'U') IS NOT NULL 
                              DROP TABLE @scratchDatabaseSchema.@tempHeelPrefix_@heelName;",
                              scratchDatabaseSchema = scratchDatabaseSchema, 
                              tempHeelPrefix = tempHeelPrefix,
                              heelName = gsub(pattern = ".sql", replacement = "", x = basename(heelFile)))$sql
  sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
  
  if (!sqlOnly) {
    connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
    DatabaseConnector::executeSql(connection = connection, sql = sql)
    DatabaseConnector::disconnect(connection = connection)
  }
}


.runAchillesAnalysisId <- function(analysisId, 
                                   connectionDetails,
                                   connection,
                                   schemaDelim,
                                   cdmDatabaseSchema,
                                   cdmVersion,
                                   scratchDatabaseSchema,
                                   tempAchillesPrefix, 
                                   detailTables,
                                   sourceName,
                                   numThreads,
                                   sqlOnly = FALSE) {
  outputFolder <- "output"
  
  if (scratchDatabaseSchema != "#") {
    .dropAchillesScratchTable(analysisId = analysisId,
                              connectionDetails = connectionDetails, 
                              scratchDatabaseSchema = scratchDatabaseSchema, 
                              tempAchillesPrefix = tempAchillesPrefix, 
                              detailTables = detailTables,
                              sqlOnly = sqlOnly)
  }
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path("analyses", paste(analysisId, "sql", sep = ".")),
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           schemaDelim = schemaDelim,
                                           tempAchillesPrefix = tempAchillesPrefix,
                                           source_name = sourceName,
                                           achilles_version = packageVersion(pkg = "Achilles"),
                                           cdmVersion = cdmVersion,
                                           singleThreaded = (scratchDatabaseSchema == "#"))
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, 
                        targetFile = 
                          paste(outputFolder, 
                                paste(paste("analysis", analysisId, sep = "_"), "sql", sep = "."), sep = "/"))
  } else {
    if (numThreads > 1) {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      DatabaseConnector::executeSql(connection = connection, sql = sql)
      DatabaseConnector::disconnect(connection = connection)
    } else {
      # connection is already alive
      DatabaseConnector::executeSql(connection = connection, sql = sql)
    }
  }
}

.mergeAchillesScratchTables <- function(detailTable, 
                                        createTable,
                                        connectionDetails,
                                        connection,
                                        schemaDelim,
                                        scratchDatabaseSchema,
                                        resultsDatabaseSchema, 
                                        cdmVersion,
                                        tempAchillesPrefix,
                                        sqlOnly,
                                        numThreads,
                                        smallcellcount = 5) {
  outputFolder <- "output"
  
  castedNames <- apply(detailTable$schema, 1, function(field) {
    SqlRender::renderSql("cast(@fieldName as @fieldType) as @fieldName", 
                         fieldName = field["FIELD_NAME"],
                         fieldType = field["FIELD_TYPE"])$sql
  })
  
  detailSqls <- lapply(detailTable$analysisIds, function(analysisId) {
    sql <- SqlRender::renderSql(sql = "select @castedNames from @scratchDatabaseSchema@schemaDelim@tablePrefix_@analysisId", 
                                scratchDatabaseSchema = scratchDatabaseSchema,
                                schemaDelim = schemaDelim,
                                castedNames = paste(castedNames, collapse = ", "), 
                                tablePrefix = detailTable$tablePrefix, 
                                analysisId = analysisId)$sql
    
    sql <- SqlRender::translateSql(sql = sql, targetDialect = connectionDetails$dbms)$sql
  })
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = "analyses/merge_achilles_tables.sql",
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           createTable = createTable,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           detailType = detailTable$detailType,
                                           detailSqls = paste(detailSqls, collapse = " \nunion all\n "),
                                           fieldNames = paste(detailTable$schema$FIELD_NAME, collapse = ", "),
                                           smallCellCount = smallcellcount)
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, 
                        targetFile = file.path(outputFolder, 
                                           paste(paste("Merge", detailTable$detailType, sep = "_"), "sql", sep = ".")))
  } else {
    if (numThreads > 1) {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      DatabaseConnector::executeSql(connection = connection, sql = sql)
      DatabaseConnector::disconnect(connection = connection)
    } else {
      # connection is already alive
      DatabaseConnector::executeSql(connection = connection, sql = sql)
    }
  }
}

.runHeelId <- function(heelFile, 
                       connectionDetails, 
                       connection,
                       cdmDatabaseSchema,
                       resultsDatabaseSchema,
                       scratchDatabaseSchema,
                       schemaDelim,
                       tempHeelPrefix, 
                       numThreads,
                       sqlOnly, 
                       inputFolder,
                       outputFolder) {
  
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = gsub(pattern = 
                                                                file.path(system.file(package = "Achilles"), 
                                                                      "sql/sql_server/"), 
                                                              replacement = "", x = heelFile),
                                           packageName = "Achilles",
                                           dbms = connectionDetails$dbms,
                                           cdmDatabaseSchema = cdmDatabaseSchema,
                                           resultsDatabaseSchema = resultsDatabaseSchema,
                                           scratchDatabaseSchema = scratchDatabaseSchema,
                                           schemaDelim = schemaDelim,
                                           tempHeelPrefix = tempHeelPrefix,
                                           heelName = gsub(pattern = ".sql", replacement = "", x = basename(heelFile)))
  
  if (sqlOnly) {
    SqlRender::writeSql(sql = sql, targetFile = paste(outputFolder, basename(heelFile), sep = "/"))
  } else {
    if (numThreads > 1) {
      connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
      DatabaseConnector::executeSql(connection = connection, sql = sql)
      DatabaseConnector::disconnect(connection = connection)
    }
    else {
      # connection is already alive
      DatabaseConnector::executeSql(connection = connection, sql = sql)
    }
  }
}



#new function to extract Heel resutls now when there are extra columns from inside R
#' @export
fetchAchillesHeelResults <- function (connectionDetails, resultsDatabaseSchema){
  connectionDetails$schema = resultsDatabaseSchema
  conn <- DatabaseConnector::connect(connectionDetails)
  
  
  sql <- "SELECT * FROM ACHILLES_heel_results"
  sql <- SqlRender::renderSql(sql)$sql
  res <- DatabaseConnector::querySql(conn,sql)
  DatabaseConnector::disconnect(conn)
  res
}


generateAOMeasurementReports <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating Measurement reports")
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlPrevalenceByGenderAgeYear.sql",
                                                                      packageName = "Achilles",
                                                                      dbms = connectionDetails$dbms,
                                                                      warnOnMissingParameters = FALSE,
                                                                      cdm_database_schema = cdmDatabaseSchema,
                                                                      results_database_schema = resultsDatabaseSchema,
                                                                      vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlPrevalenceByMonth.sql",
                                                              packageName = "Achilles",
                                                              dbms = connectionDetails$dbms,
                                                              warnOnMissingParameters = FALSE,
                                                              cdm_database_schema = cdmDatabaseSchema,
                                                              results_database_schema = resultsDatabaseSchema,
                                                              vocab_database_schema = vocabDatabaseSchema
  )
  
  queryFrequencyDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlFrequencyDistribution.sql", 
                                                                  packageName = "Achilles",
                                                                  dbms = connectionDetails$dbms,
                                                                  warnOnMissingParameters = FALSE,
                                                                  cdm_database_schema = cdmDatabaseSchema,
                                                                  results_database_schema = resultsDatabaseSchema,
                                                                  vocab_database_schema = vocabDatabaseSchema
  )
  
  queryMeasurementsByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlMeasurementsByType.sql",
                                                               packageName = "Achilles",
                                                               dbms = connectionDetails$dbms,
                                                               warnOnMissingParameters = FALSE,
                                                               cdm_database_schema = cdmDatabaseSchema,
                                                               results_database_schema = resultsDatabaseSchema,
                                                               vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlAgeAtFirstOccurrence.sql",
                                                                 packageName = "Achilles",
                                                                 dbms = connectionDetails$dbms,
                                                                 warnOnMissingParameters = FALSE,
                                                                 cdm_database_schema = cdmDatabaseSchema,
                                                                 results_database_schema = resultsDatabaseSchema,
                                                                 vocab_database_schema = vocabDatabaseSchema
  )
  
  queryRecordsByUnit <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlRecordsByUnit.sql",
                                                          packageName = "Achilles",
                                                          dbms = connectionDetails$dbms,
                                                          warnOnMissingParameters = FALSE,
                                                          cdm_database_schema = cdmDatabaseSchema,
                                                          results_database_schema = resultsDatabaseSchema,
                                                          vocab_database_schema = vocabDatabaseSchema
  )
  
  queryMeasurementValueDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlMeasurementValueDistribution.sql",
                                                                         packageName = "Achilles",
                                                                         dbms = connectionDetails$dbms,
                                                                         warnOnMissingParameters = FALSE,
                                                                         cdm_database_schema = cdmDatabaseSchema,
                                                                         results_database_schema = resultsDatabaseSchema,
                                                                         vocab_database_schema = vocabDatabaseSchema
  )
  
  queryLowerLimitDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlLowerLimitDistribution.sql",
                                                                   packageName = "Achilles",
                                                                   dbms = connectionDetails$dbms,
                                                                   warnOnMissingParameters = FALSE,
                                                                   cdm_database_schema = cdmDatabaseSchema,
                                                                   results_database_schema = resultsDatabaseSchema,
                                                                   vocab_database_schema = vocabDatabaseSchema
  )
  
  queryUpperLimitDistribution <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlUpperLimitDistribution.sql",
                                                                   packageName = "Achilles",
                                                                   dbms = connectionDetails$dbms,
                                                                   warnOnMissingParameters = FALSE,
                                                                   cdm_database_schema = cdmDatabaseSchema,
                                                                   results_database_schema = resultsDatabaseSchema,
                                                                   vocab_database_schema = vocabDatabaseSchema
  )
  
  queryValuesRelativeToNorm <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlValuesRelativeToNorm.sql",
                                                                 packageName = "Achilles",
                                                                 dbms = connectionDetails$dbms,
                                                                 warnOnMissingParameters = FALSE,
                                                                 cdm_database_schema = cdmDatabaseSchema,
                                                                 results_database_schema = resultsDatabaseSchema,
                                                                 vocab_database_schema = vocabDatabaseSchema
  )
  conn <- DatabaseConnector::connect(connectionDetails)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)  
  dataMeasurementsByType <- DatabaseConnector::querySql(conn,queryMeasurementsByType)    
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn,queryAgeAtFirstOccurrence)
  dataRecordsByUnit <- DatabaseConnector::querySql(conn,queryRecordsByUnit)
  dataMeasurementValueDistribution <- DatabaseConnector::querySql(conn,queryMeasurementValueDistribution)
  dataLowerLimitDistribution <- DatabaseConnector::querySql(conn,queryLowerLimitDistribution)
  dataUpperLimitDistribution <- DatabaseConnector::querySql(conn,queryUpperLimitDistribution)
  dataValuesRelativeToNorm <- DatabaseConnector::querySql(conn,queryValuesRelativeToNorm)
  dataFrequencyDistribution <- DatabaseConnector::querySql(conn,queryFrequencyDistribution)
  
  uniqueConcepts <- unique(dataPrevalenceByMonth$CONCEPT_ID)

  buildMeasurementReport <- function(concept_id) {
    report <- {}
    report$CONCEPT_ID = concept_id
    report$CONCEPT_NAME = dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,2][[1]]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$FREQUENCY_DISTRIBUTION <- dataFrequencyDistribution[dataFrequencyDistribution$CONCEPT_ID == concept_id,c(3,4)]
    report$MEASUREMENTS_BY_TYPE <- dataMeasurementsByType[dataMeasurementsByType$MEASUREMENT_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    
    report$RECORDS_BY_UNIT <- dataRecordsByUnit[dataRecordsByUnit$MEASUREMENT_CONCEPT_ID == concept_id,c(4,5)]
    report$MEASUREMENT_VALUE_DISTRIBUTION <- dataMeasurementValueDistribution[dataMeasurementValueDistribution$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$LOWER_LIMIT_DISTRIBUTION <- dataLowerLimitDistribution[dataLowerLimitDistribution$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$UPPER_LIMIT_DISTRIBUTION <- dataUpperLimitDistribution[dataUpperLimitDistribution$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$VALUES_RELATIVE_TO_NORM <- dataValuesRelativeToNorm[dataValuesRelativeToNorm$MEASUREMENT_CONCEPT_ID == concept_id,c(4,5)]
    
    filename <- paste(outputPath, "/concepts/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildMeasurementReport)  
}

generateAOConditionReports <- function(connectionDetails,cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating condition reports")
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlPrevalenceByGenderAgeYear.sql",
                                                                      packageName = "Achilles",
                                                                      dbms = connectionDetails$dbms,
                                                                      warnOnMissingParameters = FALSE,
                                                                      cdm_database_schema = cdmDatabaseSchema,
                                                                      results_database_schema = resultsDatabaseSchema,
                                                                      vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlPrevalenceByMonth.sql",
                                                              packageName = "Achilles",
                                                              dbms = connectionDetails$dbms,
                                                              warnOnMissingParameters = FALSE,
                                                              cdm_database_schema = cdmDatabaseSchema,
                                                              results_database_schema = resultsDatabaseSchema,
                                                              vocab_database_schema = vocabDatabaseSchema
  )
  
  queryConditionsByType <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlConditionsByType.sql",
                                                             packageName = "Achilles",
                                                             dbms = connectionDetails$dbms,
                                                             warnOnMissingParameters = FALSE,
                                                             cdm_database_schema = cdmDatabaseSchema,
                                                             results_database_schema = resultsDatabaseSchema,
                                                             vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstDiagnosis <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlAgeAtFirstDiagnosis.sql",
                                                                packageName = "Achilles",
                                                                dbms = connectionDetails$dbms,
                                                                warnOnMissingParameters = FALSE,
                                                                cdm_database_schema = cdmDatabaseSchema,
                                                                results_database_schema = resultsDatabaseSchema,
                                                                vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)  
  dataConditionsByType <- DatabaseConnector::querySql(conn,queryConditionsByType)    
  dataAgeAtFirstDiagnosis <- DatabaseConnector::querySql(conn,queryAgeAtFirstDiagnosis)      
  uniqueConcepts <- unique(dataPrevalenceByMonth$CONCEPT_ID)

  buildConditionReport <- function(concept_id) {
    report <- {}
    report$CONCEPT_ID = concept_id
    report$CONCEPT_NAME = dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,2][[1]]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$CONDITIONS_BY_TYPE <- dataConditionsByType[dataConditionsByType$CONDITION_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_DIAGNOSIS <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    
    filename <- paste(outputPath, "/concepts/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildConditionReport)  
}

#' @title exportAO
#'
#' @description
#' \code{exportAO} Exports Achilles statistics - alpha option
#'
#' @details
#' Creates export files 
#' 
#' 
#' @param connectionDetails             An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmDatabaseSchema             Name of the database schema that contains the OMOP CDM.
#' @param resultsDatabaseSchema     		Name of the database schema that contains the Achilles analysis files. Default is cdmDatabaseSchema
#' @param outputPath		                A folder location to save the JSON files. Default is current working folder
#' @param vocabDatabaseSchema		        string name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' 
#' See \code{showReportTypes} for a list of all report types
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportToJson(connectionDetails, cdmDatabaseSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportAO <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  conn <- DatabaseConnector::connect(connectionDetails)
  
  # generate a folder name for this release of the cdm characterization
  sql <- SqlRender::render(sql = "select * from @cdmDatabaseSchema.cdm_source;",
                           cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  metadata <- DatabaseConnector::querySql(conn, sql)
  sourceOutputPath <- file.path(outputPath, metadata$CDM_SOURCE_ABBREVIATION,format(metadata$CDM_RELEASE_DATE, "%Y%m%d"))
  dir.create(sourceOutputPath,showWarnings = F,recursive=T)
  print(paste0("processing AO export to ", sourceOutputPath))
  
  # data density - totals
  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/datadensity/totalrecords.sql",
                                                   packageName = "Achilles",
                                                   dbms = connectionDetails$dbms,
                                                   warnOnMissingParameters = FALSE,
                                                   cdm_database_schema = cdmDatabaseSchema,
                                                   results_database_schema = resultsDatabaseSchema,
                                                   vocab_database_schema = vocabDatabaseSchema
  )  
  
  totalRecordsData <- DatabaseConnector::querySql(conn,renderedSql)
  colnames(totalRecordsData) <- c("domain", "date", "records")  
  totalRecordsData$date <- lubridate::parse_date_time(totalRecordsData$date, "ym")
  data.table::fwrite(totalRecordsData, file=paste0(sourceOutputPath, "/datadensity-total.csv"))
  
  # data density - records per person
  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/datadensity/recordsperperson.sql",
                                                   packageName = "Achilles",
                                                   dbms = connectionDetails$dbms,
                                                   warnOnMissingParameters = FALSE,
                                                   cdm_database_schema = cdmDatabaseSchema,
                                                   results_database_schema = resultsDatabaseSchema,
                                                   vocab_database_schema = vocabDatabaseSchema
  )  
  
  recordsPerPerson <- DatabaseConnector::querySql(conn,renderedSql)
  colnames(recordsPerPerson) <- c("domain", "date", "records")
  recordsPerPerson$date <- lubridate::parse_date_time(recordsPerPerson$date, "ym")  
  recordsPerPerson$records <- round(recordsPerPerson$records,2)
  data.table::fwrite(recordsPerPerson, file=paste0(sourceOutputPath, "/datadensity-records-per-person.csv"))  

  # data density - concepts  per person
  renderedSql <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/datadensity/conceptsperperson.sql",
                                                   packageName = "Achilles",
                                                   dbms = connectionDetails$dbms,
                                                   warnOnMissingParameters = FALSE,
                                                   cdm_database_schema = cdmDatabaseSchema,
                                                   results_database_schema = resultsDatabaseSchema,
                                                   vocab_database_schema = vocabDatabaseSchema
  )  
  conceptsPerPerson <- DatabaseConnector::querySql(conn,renderedSql)
  data.table::fwrite(conceptsPerPerson, file=paste0(sourceOutputPath, "/datadensity-concepts-per-person.csv"))
  
  # domain summary - conditions
  queryConditions <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/condition/sqlConditionTable.sql",
                                                             packageName = "Achilles",
                                                             dbms = connectionDetails$dbms,
                                                             warnOnMissingParameters = FALSE,
                                                             cdm_database_schema = cdmDatabaseSchema,
                                                             results_database_schema = resultsDatabaseSchema,
                                                             vocab_database_schema = vocabDatabaseSchema
  )  
  dataConditions <- DatabaseConnector::querySql(conn,queryConditions)   
  dataConditions$PERCENT_PERSONS <- format(round(dataConditions$PERCENT_PERSONS,2), nsmall=2)
  dataConditions$RECORDS_PER_PERSON <- format(round(dataConditions$RECORDS_PER_PERSON,1),nsmall=1)
  data.table::fwrite(dataConditions, file=paste0(sourceOutputPath, "/condition-domain-summary.csv"))  
  
  # domain summary - drugs
  queryDrugs <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/drug/sqlDrugTable.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       warnOnMissingParameters = FALSE,
                                                       cdm_database_schema = cdmDatabaseSchema,
                                                       results_database_schema = resultsDatabaseSchema,
                                                       vocab_database_schema = vocabDatabaseSchema
  )  
  dataDrugs <- DatabaseConnector::querySql(conn,queryDrugs)   
  dataDrugs$PERCENT_PERSONS <- format(round(dataDrugs$PERCENT_PERSONS,2), nsmall=2)
  dataDrugs$RECORDS_PER_PERSON <- format(round(dataDrugs$RECORDS_PER_PERSON,1),nsmall=1)
  data.table::fwrite(dataDrugs, file=paste0(sourceOutputPath, "/drug-domain-summary.csv"))    
  
  # domain summary - measurements
  queryMeasurements <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/measurement/sqlMeasurementTable.sql",
                                                       packageName = "Achilles",
                                                       dbms = connectionDetails$dbms,
                                                       warnOnMissingParameters = FALSE,
                                                       cdm_database_schema = cdmDatabaseSchema,
                                                       results_database_schema = resultsDatabaseSchema,
                                                       vocab_database_schema = vocabDatabaseSchema
  )  
  dataMeasurements <- DatabaseConnector::querySql(conn,queryMeasurements)   
  dataMeasurements$PERCENT_PERSONS <- format(round(dataMeasurements$PERCENT_PERSONS,2), nsmall=2)
  dataMeasurements$RECORDS_PER_PERSON <- format(round(dataMeasurements$RECORDS_PER_PERSON,1),nsmall=1)
  data.table::fwrite(dataMeasurements, file=paste0(sourceOutputPath, "/measurement-domain-summary.csv"))   
  
  # domain summary - procedures
  queryProcedures <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/procedure/sqlProcedureTable.sql",
                                                         packageName = "Achilles",
                                                         dbms = connectionDetails$dbms,
                                                         warnOnMissingParameters = FALSE,
                                                         cdm_database_schema = cdmDatabaseSchema,
                                                         results_database_schema = resultsDatabaseSchema,
                                                         vocab_database_schema = vocabDatabaseSchema
  )  
  dataProcedures <- DatabaseConnector::querySql(conn,queryProcedures)   
  dataProcedures$PERCENT_PERSONS <- format(round(dataProcedures$PERCENT_PERSONS,2), nsmall=2)
  dataProcedures$RECORDS_PER_PERSON <- format(round(dataProcedures$RECORDS_PER_PERSON,1),nsmall=1)
  data.table::fwrite(dataProcedures, file=paste0(sourceOutputPath, "/procedure-domain-summary.csv"))   
  
  # concept level reporting
  conceptsFolder <- file.path(sourceOutputPath,"concepts")
  dir.create(conceptsFolder,showWarnings = F)
  
  generateAOMeasurementReports(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
  generateAOConditionReports(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)  
}

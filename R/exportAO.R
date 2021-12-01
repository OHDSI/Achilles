
generateAOProcedureReports <- function(connectionDetails, proceduresData, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating procedure reports")
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/procedure/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/procedure/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryProcedureFrequencyDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/procedure/sqlFrequencyDistribution.sql", 
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryProceduresByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/procedure/sqlProceduresByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/procedure/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)  
  dataProceduresByType <- DatabaseConnector::querySql(conn,queryProceduresByType)    
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn,queryAgeAtFirstOccurrence)    
  dataProcedureFrequencyDistribution <- DatabaseConnector::querySql(conn,queryProcedureFrequencyDistribution)
  
  buildProcedureReport <- function(concept_id) {
    summaryRecord <- proceduresData[proceduresData$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$CDM_TABLE_NAME <- "PROCEDURE_OCCURRENCE"
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON    
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$PROCEDURE_FREQUENCY_DISTRIBUTION <- dataProcedureFrequencyDistribution[dataProcedureFrequencyDistribution$CONCEPT_ID == concept_id,c(3,4)]
    report$PROCEDURES_BY_TYPE <- dataProceduresByType[dataProceduresByType$PROCEDURE_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]

    dir.create(paste0(outputPath,"/concepts/procedure_occurrence"),recursive=T,showWarnings = F)        
    filename <- paste(outputPath, "/concepts/procedure_occurrence/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }

  uniqueConcepts <- unique(proceduresData$CONCEPT_ID)
  x <- lapply(uniqueConcepts, buildProcedureReport)  
}

generateAOPersonReport <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating person report")
  output = {}
  conn <- DatabaseConnector::connect(connectionDetails)
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/population.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  personSummaryData <- DatabaseConnector::querySql(conn,renderedSql)
  output$SUMMARY = personSummaryData
  
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/population_age_gender.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  ageGenderData <- DatabaseConnector::querySql(conn,renderedSql)
  output$AGE_GENDER_DATA = ageGenderData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/gender.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  genderData <- DatabaseConnector::querySql(conn,renderedSql)
  output$GENDER_DATA = genderData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/race.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  raceData <- DatabaseConnector::querySql(conn,renderedSql)
  output$RACE_DATA = raceData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/ethnicity.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  ethnicityData <- DatabaseConnector::querySql(conn,renderedSql)
  output$ETHNICITY_DATA = ethnicityData
  

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/yearofbirth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
                                                   warnOnMissingParameters = FALSE,
                                                   cdm_database_schema = cdmDatabaseSchema,
                                                   results_database_schema = resultsDatabaseSchema,
                                                   vocab_database_schema = vocabDatabaseSchema
  )
  birthYearData <- DatabaseConnector::querySql(conn,renderedSql)
  output$BIRTH_YEAR_DATA <- birthYearData
  
  jsonOutput = jsonlite::toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/person.json", sep=""))
}

generateAOAchillesPerformanceReport <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath) 
{
  writeLines("Generating achilles performance report")

  queryAchillesPerformance <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/performance/sqlAchillesPerformance.sql",
                                                                packageName = "Achilles",
                                                                dbms = connectionDetails$dbms,
                                                                warnOnMissingParameters = FALSE,
                                                                cdm_database_schema = cdmDatabaseSchema,
                                                                results_database_schema = resultsDatabaseSchema,
                                                                vocab_database_schema = vocabDatabaseSchema
  )  
  
  conn <- DatabaseConnector::connect(connectionDetails)
  dataPerformance <- DatabaseConnector::querySql(conn,queryAchillesPerformance)
  names(dataPerformance) <- c("analysis_id", "analysis_name", "elapsed_seconds")
  dataPerformance$elapsed_seconds <- format(round(as.numeric(gsub(" secs","",dataPerformance$elapsed_seconds)),digits = 2),nsmall = 2)
  data.table::fwrite(dataPerformance, file.path(outputPath, "achilles-performance.csv"))
}

generateAODeathReport <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating death report")

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/death/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )  
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/death/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )  

  queryDeathByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/death/sqlDeathByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtDeath <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/death/sqlAgeAtDeath.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )  
  
  conn <- DatabaseConnector::connect(connectionDetails)
  
  deathByTypeData <- DatabaseConnector::querySql(conn,queryDeathByType)
  prevalenceByGenderAgeYearData <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear)
  prevalenceByMonthData <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)
  ageAtDeathData <- DatabaseConnector::querySql(conn,queryAgeAtDeath)
  
  output = {}  
  output$PREVALENCE_BY_GENDER_AGE_YEAR = prevalenceByGenderAgeYearData  
  output$PREVALENCE_BY_MONTH = prevalenceByMonthData
  output$DEATH_BY_TYPE = deathByTypeData  
  output$AGE_AT_DEATH = ageAtDeathData
  
  filename <- file.path(outputPath, "death.json")  
  write(jsonlite::toJSON(output),filename)  
}

generateAOObservationPeriodReport <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating observation period reports")
  conn <- DatabaseConnector::connect(connectionDetails)
  
  output = {}
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/ageatfirst.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  ageAtFirstObservationData <- DatabaseConnector::querySql(conn,renderedSql)
  output$AGE_AT_FIRST_OBSERVATION <- ageAtFirstObservationData
  
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/agebygender.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  ageByGenderData <- DatabaseConnector::querySql(conn,renderedSql)
  output$AGE_BY_GENDER = ageByGenderData

  observationLengthHist <- {}
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observationlength_stats.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observationLengthStats <- DatabaseConnector::querySql(conn,renderedSql)
  observationLengthHist$MIN = observationLengthStats$MIN_VALUE
  observationLengthHist$MAX = observationLengthStats$MAX_VALUE
  observationLengthHist$INTERVAL_SIZE = observationLengthStats$INTERVAL_SIZE
  observationLengthHist$INTERVALS = (observationLengthStats$MAX_VALUE - observationLengthStats$MIN_VALUE) / observationLengthStats$INTERVAL_SIZE
  
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observationlength_data.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observationLengthData <- DatabaseConnector::querySql(conn,renderedSql)
  output$OBSERVATION_LENGTH_HISTOGRAM = observationLengthHist

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/cumulativeduration.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  cumulativeDurationData <- DatabaseConnector::querySql(conn,renderedSql)
  cumulativeDurationData$X_LENGTH_OF_OBSERVATION <- cumulativeDurationData$X_LENGTH_OF_OBSERVATION / 365.25
  cumulativeDurationData$SERIES_NAME <- NULL
  names(cumulativeDurationData) <- c("YEARS","PERCENT_PEOPLE")
  output$CUMULATIVE_DURATION = cumulativeDurationData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observationlengthbygender.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  opLengthByGenderData <- DatabaseConnector::querySql(conn,renderedSql)
  opLengthByGenderData$MIN_VALUE <- opLengthByGenderData$MIN_VALUE / 365.25
  opLengthByGenderData$P10_VALUE <- opLengthByGenderData$P10_VALUE / 365.25
  opLengthByGenderData$P25_VALUE <- opLengthByGenderData$P25_VALUE / 365.25
  opLengthByGenderData$MEDIAN_VALUE <- opLengthByGenderData$MEDIAN_VALUE / 365.25
  opLengthByGenderData$P75_VALUE <- opLengthByGenderData$P75_VALUE / 365.25
  opLengthByGenderData$P90_VALUE <- opLengthByGenderData$P90_VALUE / 365.25
  opLengthByGenderData$MAX_VALUE <- opLengthByGenderData$MAX_VALUE / 365.25
  
  output$OBSERVATION_PERIOD_LENGTH_BY_GENDER = opLengthByGenderData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observationlengthbyage.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  opLengthByAgeData <- DatabaseConnector::querySql(conn,renderedSql)
  opLengthByAgeData$MIN_VALUE <- opLengthByAgeData$MIN_VALUE / 365.25
  opLengthByAgeData$P10_VALUE <- opLengthByAgeData$P10_VALUE / 365.25
  opLengthByAgeData$P25_VALUE <- opLengthByAgeData$P25_VALUE / 365.25
  opLengthByAgeData$MEDIAN_VALUE <- opLengthByAgeData$MEDIAN_VALUE / 365.25
  opLengthByAgeData$P75_VALUE <- opLengthByAgeData$P75_VALUE / 365.25
  opLengthByAgeData$P90_VALUE <- opLengthByAgeData$P90_VALUE / 365.25
  opLengthByAgeData$MAX_VALUE <- opLengthByAgeData$MAX_VALUE / 365.25
  output$OBSERVATION_PERIOD_LENGTH_BY_AGE = opLengthByAgeData

  observedByYearHist <- {}
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observedbyyear_stats.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observedByYearStats <- DatabaseConnector::querySql(conn,renderedSql)
  observedByYearHist$MIN = observedByYearStats$MIN_VALUE
  observedByYearHist$MAX = observedByYearStats$MAX_VALUE
  observedByYearHist$INTERVAL_SIZE = observedByYearStats$INTERVAL_SIZE
  observedByYearHist$INTERVALS = (observedByYearStats$MAX_VALUE - observedByYearStats$MIN_VALUE) / observedByYearStats$INTERVAL_SIZE
  
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observedbyyear_data.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observedByYearData <- DatabaseConnector::querySql(conn,renderedSql)
  observedByYearHist$DATA <- observedByYearData
  output$OBSERVED_BY_YEAR_HISTOGRAM = observedByYearHist
  
  observedByMonth <- {}
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observedbymonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observedByMonth <- DatabaseConnector::querySql(conn,renderedSql)
  output$OBSERVED_BY_MONTH = observedByMonth

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/periodsperperson.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  personPeriodsData <- DatabaseConnector::querySql(conn,renderedSql)
  output$PERSON_PERIODS_DATA = personPeriodsData
  
  filename <- file.path(outputPath, "observationperiod.json")
  write(jsonlite::toJSON(output),filename)  
}

generateAOVisitReports <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating visit reports")
  
  queryVisits <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlVisitTreemap.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryVisitDurationByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlVisitDurationByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)
  dataVisits <-  DatabaseConnector::querySql(conn,queryVisits) 
  names(dataVisits)[names(dataVisits) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)  
  dataVisitDurationByType <- DatabaseConnector::querySql(conn,queryVisitDurationByType)    
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn,queryAgeAtFirstOccurrence)    
  
  buildVisitReport <- function(concept_id) {
    summaryRecord <- dataVisits[dataVisits$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "VISIT_OCCURRENCE"    
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON    
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$VISIT_DURATION_BY_TYPE <- dataVisitDurationByType[dataVisitDurationByType$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    
    dir.create(paste0(outputPath,"/concepts/visit_occurrence"),recursive=T,showWarnings = F)
    filename <- paste(outputPath, "/concepts/visit_occurrence/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  uniqueConcepts <- unique(dataVisits$CONCEPT_ID)
  x <- lapply(uniqueConcepts, buildVisitReport)  
}

generateAOVisitDetailReports <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating visit_detail reports")
  
  queryVisitDetails <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visitdetail/sqlVisitDetailTreemap.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visitdetail/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visitdetail/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryVisitDetailDurationByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visitdetail/sqlVisitDetailDurationByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visitdetail/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)
  dataVisitDetails <- DatabaseConnector::querySql(conn,queryVisitDetails)
  names(dataVisitDetails)[names(dataVisitDetails) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)  
  dataVisitDetailDurationByType <- DatabaseConnector::querySql(conn,queryVisitDetailDurationByType)    
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn,queryAgeAtFirstOccurrence)    
  
  buildVisitDetailReport <- function(concept_id) {
    summaryRecord <- dataVisitDetails[dataVisitDetails$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "VISIT_DETAIL"    
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON  
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$VISIT_DETAIL_DURATION_BY_TYPE <- dataVisitDetailDurationByType[dataVisitDetailDurationByType$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]

    dir.create(paste0(outputPath,"/concepts/visit_detail"),recursive=T,showWarnings = F)    
    filename <- paste(outputPath, "/concepts/visit_detail/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)      
  }
  
  uniqueConcepts <- unique(dataVisitDetails$CONCEPT_ID)  
  x <- lapply(uniqueConcepts, buildVisitDetailReport)  
}

generateAOMetadataReport <- function(connectionDetails, cdmDatabaseSchema, outputPath)
{
  conn <- DatabaseConnector::connect(connectionDetails)
  if ("METADATA" %in% DatabaseConnector::getTableNames(connection = conn, databaseSchema = cdmDatabaseSchema))
  {
    writeLines("Generating metadata report")    
    queryMetadata <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/metadata/sqlMetadata.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      cdm_database_schema = cdmDatabaseSchema
    )      
    dataMetadata <- DatabaseConnector::querySql(conn, queryMetadata) 
    data.table::fwrite(dataMetadata, file=paste0(outputPath, "/metadata.csv"))   
  }
}

generateAOObservationReports <- function(connectionDetails, observationsData, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating Observation reports")

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observation/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observation/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryObsFrequencyDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observation/sqlFrequencyDistribution.sql", 
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryObservationsByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observation/sqlObservationsByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observation/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)  
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)  
  dataObservationsByType <- DatabaseConnector::querySql(conn,queryObservationsByType)    
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn,queryAgeAtFirstOccurrence)
  dataObsFrequencyDistribution <- DatabaseConnector::querySql(conn,queryObsFrequencyDistribution)
  
  uniqueConcepts <- unique(observationsData$CONCEPT_ID)  
  buildObservationReport <- function(concept_id) {
    summaryRecord <- observationsData[observationsData$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$CDM_TABLE_NAME <- "OBSERVATION"
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON  
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$OBS_FREQUENCY_DISTRIBUTION <- dataObsFrequencyDistribution[dataObsFrequencyDistribution$CONCEPT_ID == concept_id,c(3,4)]
    report$OBSERVATIONS_BY_TYPE <- dataObservationsByType[dataObservationsByType$OBSERVATION_CONCEPT_ID == concept_id,c(4,5)]
    report$AGE_AT_FIRST_OCCURRENCE <- dataAgeAtFirstOccurrence[dataAgeAtFirstOccurrence$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    
    dir.create(paste0(outputPath,"/concepts/observation"),recursive=T,showWarnings = F)    
    filename <- paste(outputPath, "/concepts/observation/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  uniqueConcepts <- unique(observationsData$CONCEPT_ID)
  x <- lapply(uniqueConcepts, buildObservationReport)  
}

generateAOCdmSourceReport <- function(connectionDetails, cdmDatabaseSchema, outputPath)
{
  conn <- DatabaseConnector::connect(connectionDetails)  
  if ("CDM_SOURCE" %in% DatabaseConnector::getTableNames(connection = conn, databaseSchema = cdmDatabaseSchema))
  {
    writeLines("Generating cdm source report")    
    queryCdmSource <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/metadata/sqlCdmSource.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      cdm_database_schema = cdmDatabaseSchema
    )  
    
    dataCdmSource <- DatabaseConnector::querySql(conn, queryCdmSource) 
    data.table::fwrite(dataCdmSource, file=paste0(outputPath, "/cdmsource.csv"))
  }
}

generateAODashboardReport <- function(outputPath)
{
  output <- {}
  personReport <- rjson::fromJSON(file = paste(outputPath, "/person.json", sep=""))
  output$SUMMARY <- personReport$SUMMARY
  output$GENDER_DATA <- personReport$GENDER_DATA
  opReport <- rjson::fromJSON(file = paste(outputPath, "/observationperiod.json", sep=""))
  
  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM = opReport$AGE_AT_FIRST_OBSERVATION_HISTOGRAM
  output$CUMULATIVE_DURATION = opReport$CUMULATIVE_DURATION
  output$OBSERVED_BY_MONTH = opReport$OBSERVED_BY_MONTH

  jsonOutput =jsonlite::toJSON(output)
  write(jsonOutput, file=paste(outputPath, "/dashboard.json", sep=""))  
}

generateAOMeasurementReports <- function(connectionDetails, dataMeasurements, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating Measurement reports")
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryFrequencyDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlFrequencyDistribution.sql", 
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryMeasurementsByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlMeasurementsByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstOccurrence <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlAgeAtFirstOccurrence.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryRecordsByUnit <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlRecordsByUnit.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryMeasurementValueDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlMeasurementValueDistribution.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryLowerLimitDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlLowerLimitDistribution.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryUpperLimitDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlUpperLimitDistribution.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryValuesRelativeToNorm <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlValuesRelativeToNorm.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
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
    summaryRecord <- dataMeasurements[dataMeasurements$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "MEASUREMENT"    
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON
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
	    
    dir.create(paste0(outputPath,"/concepts/measurement"),recursive=T,showWarnings = F)    
    filename <- paste(outputPath, "/concepts/measurement/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildMeasurementReport)  
}

generateAODrugEraReports <- function(connectionDetails, dataDrugEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath) 
{
  writeLines("Generating drug era reports")

  queryAgeAtFirstExposure <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drugera/sqlAgeAtFirstExposure.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drugera/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drugera/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryLengthOfEra <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drugera/sqlLengthOfEra.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )

  conn <- DatabaseConnector::connect(connectionDetails)  
  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn,queryAgeAtFirstExposure) 
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)
  dataLengthOfEra <- DatabaseConnector::querySql(conn,queryLengthOfEra)
  uniqueConcepts <- unique(dataDrugEra$CONCEPT_ID)
  buildDrugEraReport <- function(concept_id) {
    summaryRecord <- dataDrugEra[dataDrugEra$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "DRUG_ERA"
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(2,3,4,5)]  
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(2,3)]
    report$LENGTH_OF_ERA <- dataLengthOfEra[dataLengthOfEra$CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    
    dir.create(paste0(outputPath,"/concepts/drug_era"),recursive=T,showWarnings = F)        
    filename <- paste(outputPath, "/concepts/drug_era/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildDrugEraReport)  
}

generateAODrugReports <- function(connectionDetails, dataDrugs, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath) 
{
  writeLines("Generating drug reports")
  
  queryAgeAtFirstExposure <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlAgeAtFirstExposure.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryDaysSupplyDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlDaysSupplyDistribution.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryDrugsByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlDrugsByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryDrugFrequencyDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlFrequencyDistribution.sql", 
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryQuantityDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlQuantityDistribution.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryRefillsDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlRefillsDistribution.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)  
  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn,queryAgeAtFirstExposure) 
  dataDaysSupplyDistribution <- DatabaseConnector::querySql(conn,queryDaysSupplyDistribution) 
  dataDrugsByType <- DatabaseConnector::querySql(conn,queryDrugsByType) 
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)
  dataQuantityDistribution <- DatabaseConnector::querySql(conn,queryQuantityDistribution) 
  dataRefillsDistribution <- DatabaseConnector::querySql(conn,queryRefillsDistribution) 
  dataDrugFrequencyDistribution <- DatabaseConnector::querySql(conn,queryDrugFrequencyDistribution)
  
  uniqueConcepts <- unique(dataPrevalenceByMonth$CONCEPT_ID)
  buildDrugReport <- function(concept_id) {
    summaryRecord <- dataDrugs[dataDrugs$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "DRUG_EXPOSURE"
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON    
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$DRUG_CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$DAYS_SUPPLY_DISTRIBUTION <- dataDaysSupplyDistribution[dataDaysSupplyDistribution$DRUG_CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    report$DRUGS_BY_TYPE <- dataDrugsByType[dataDrugsByType$DRUG_CONCEPT_ID == concept_id, c(3,4)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]  
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$DRUG_FREQUENCY_DISTRIBUTION <- dataDrugFrequencyDistribution[dataDrugFrequencyDistribution$CONCEPT_ID == concept_id,c(3,4)]
    report$QUANTITY_DISTRIBUTION <- dataQuantityDistribution[dataQuantityDistribution$DRUG_CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    report$REFILLS_DISTRIBUTION <- dataRefillsDistribution[dataRefillsDistribution$DRUG_CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]

    dir.create(paste0(outputPath,"/concepts/drug_exposure"),recursive=T,showWarnings = F)        
    filename <- paste(outputPath, "/concepts/drug_exposure/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildDrugReport)  
}

generateAODeviceReports <- function(connectionDetails, dataDevices, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath) 
{
  writeLines("Generating device exposure reports")
  
  queryAgeAtFirstExposure <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/device/sqlAgeAtFirstExposure.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )

  queryDevicesByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/device/sqlDevicesByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/device/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/device/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryDeviceFrequencyDistribution <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/device/sqlFrequencyDistribution.sql", 
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )

  conn <- DatabaseConnector::connect(connectionDetails)  
  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn,queryAgeAtFirstExposure) 
  dataDevicesByType <- DatabaseConnector::querySql(conn,queryDevicesByType) 
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn,queryPrevalenceByGenderAgeYear) 
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn,queryPrevalenceByMonth)
  dataDeviceFrequencyDistribution <- DatabaseConnector::querySql(conn,queryDeviceFrequencyDistribution)
  
  uniqueConcepts <- unique(dataDevices$CONCEPT_ID)
  buildDeviceReport <- function(concept_id) {
    summaryRecord <- dataDevices[dataDevices$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "DEVICE_EXPOSURE"
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON    
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstExposure[dataAgeAtFirstExposure$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$DEVICES_BY_TYPE <- dataDevicesByType[dataDevicesByType$CONCEPT_ID == concept_id, c(3,4)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]  
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$DEVICE_FREQUENCY_DISTRIBUTION <- dataDeviceFrequencyDistribution[dataDeviceFrequencyDistribution$CONCEPT_ID == concept_id,c(3,4)]

    dir.create(paste0(outputPath,"/concepts/device_exposure"),recursive=T,showWarnings = F)        
    filename <- paste(outputPath, "/concepts/device_exposure/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildDeviceReport)  
}

generateAOConditionReports <- function(connectionDetails, dataConditions, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath) 
{
  writeLines("Generating condition reports")
  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/condition/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/condition/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryConditionsByType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/condition/sqlConditionsByType.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstDiagnosis <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/condition/sqlAgeAtFirstDiagnosis.sql",
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
    summaryRecord <- dataConditions[dataConditions$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "CONDITION_OCCURRENCE"
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(3,4,5,6)]    
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(3,4)]
    report$CONDITIONS_BY_TYPE <- dataConditionsByType[dataConditionsByType$CONDITION_CONCEPT_ID == concept_id,c(2,3)]
    report$AGE_AT_FIRST_DIAGNOSIS <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    
    dir.create(paste0(outputPath,"/concepts/condition_occurrence"),recursive=T,showWarnings = F)        
    filename <- paste(outputPath, "/concepts/condition_occurrence/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildConditionReport)  
}

generateAOConditionEraReports <- function(connectionDetails, dataConditionEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  writeLines("Generating condition era reports")

  queryPrevalenceByGenderAgeYear <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/conditionera/sqlPrevalenceByGenderAgeYear.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryPrevalenceByMonth <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/conditionera/sqlPrevalenceByMonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryAgeAtFirstDiagnosis <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/conditionera/sqlAgeAtFirstDiagnosis.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  queryLengthOfEra <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/conditionera/sqlLengthOfEra.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  
  conn <- DatabaseConnector::connect(connectionDetails)  
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataLengthOfEra <- DatabaseConnector::querySql(conn, queryLengthOfEra)
  dataAgeAtFirstDiagnosis <- DatabaseConnector::querySql(conn, queryAgeAtFirstDiagnosis)
  uniqueConcepts <- unique(dataConditionEra$CONCEPT_ID)

  buildConditionEraReport <- function(concept_id) {
    summaryRecord <- dataConditionEra[dataConditionEra$CONCEPT_ID==concept_id,]
    report <- {}
    report$CONCEPT_ID <- concept_id
    report$CDM_TABLE_NAME <- "CONDITION_ERA"
    report$CONCEPT_NAME <- summaryRecord$CONCEPT_NAME
    report$NUM_PERSONS <- summaryRecord$NUM_PERSONS
    report$PERCENT_PERSONS <-summaryRecord$PERCENT_PERSONS
    report$RECORDS_PER_PERSON <- summaryRecord$RECORDS_PER_PERSON
    report$AGE_AT_FIRST_EXPOSURE <- dataAgeAtFirstDiagnosis[dataAgeAtFirstDiagnosis$CONCEPT_ID == concept_id,c(2,3,4,5,6,7,8,9)]
    report$PREVALENCE_BY_GENDER_AGE_YEAR <- dataPrevalenceByGenderAgeYear[dataPrevalenceByGenderAgeYear$CONCEPT_ID == concept_id,c(2,3,4,5)]  
    report$PREVALENCE_BY_MONTH <- dataPrevalenceByMonth[dataPrevalenceByMonth$CONCEPT_ID == concept_id,c(2,3)]
    report$LENGTH_OF_ERA <- dataLengthOfEra[dataLengthOfEra$CONCEPT_ID == concept_id, c(2,3,4,5,6,7,8,9)]
    
    dir.create(paste0(outputPath,"/concepts/condition_era"),recursive=T,showWarnings = F)        
    filename <- paste(outputPath, "/concepts/condition_era/concept_" , concept_id , ".json", sep='')  
    write(jsonlite::toJSON(report),filename)  
  }
  
  x <- lapply(uniqueConcepts, buildConditionEraReport)
}

#' @title exportAO
#'
#' @description
#' \code{exportAO} Exports Achilles statistics - ares option
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
#' @param reports                       vector of reports to run, c() defaults to all reports
#' 
#' See \code{showReportTypes} for a list of all report types
#' 
#' @return none 
#' @examples \dontrun{
#'   connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="yourserver")
#'   exportToJson(connectionDetails, cdmDatabaseSchema="cdm4_sim", outputPath="your/output/path")
#' }
#' @export
exportAO <- function(
  connectionDetails, 
  cdmDatabaseSchema, 
  resultsDatabaseSchema, 
  vocabDatabaseSchema, 
  outputPath,
  reports = c())
{
  conn <- DatabaseConnector::connect(connectionDetails)
  
  # generate a folder name for this release of the cdm characterization
  sql <- SqlRender::render(sql = "select * from @cdmDatabaseSchema.cdm_source;",cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  metadata <- DatabaseConnector::querySql(conn, sql)
  sourceKey <- gsub(" ","_",metadata$CDM_SOURCE_ABBREVIATION)
  releaseDateKey <- format(lubridate::ymd(metadata$CDM_RELEASE_DATE), "%Y%m%d")
  sourceOutputPath <- file.path(outputPath, sourceKey, releaseDateKey)
  dir.create(sourceOutputPath,showWarnings = F,recursive=T)
  print(paste0("processing AO export to ", sourceOutputPath))
  
  if (length(reports) == 0  || (length(reports) > 0 && "density" %in% reports)) {
    # data density - totals
    renderedSql <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/datadensity/totalrecords.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema
    )  
    
    totalRecordsData <- DatabaseConnector::querySql(conn,renderedSql)
    colnames(totalRecordsData) <- c("domain", "date", "records")  
    totalRecordsData$date <- lubridate::parse_date_time(totalRecordsData$date, "ym")
    data.table::fwrite(totalRecordsData, file=paste0(sourceOutputPath, "/datadensity-total.csv"))
    
    domainAggregates <- aggregate(totalRecordsData$records, by=list(domain=totalRecordsData$domain), FUN=sum)
    names(domainAggregates) <- c("domain","count_records")
    data.table::fwrite(domainAggregates, file=paste0(sourceOutputPath, "/records-by-domain.csv"))

    # data density - records per person
    renderedSql <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/datadensity/recordsperperson.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema
    )
    
    recordsPerPerson <- DatabaseConnector::querySql(conn,renderedSql)
    colnames(recordsPerPerson) <- c("domain", "date", "records")
    recordsPerPerson$date <- lubridate::parse_date_time(recordsPerPerson$date, "ym")  
    recordsPerPerson$records <- round(recordsPerPerson$records,2)
    data.table::fwrite(recordsPerPerson, file=paste0(sourceOutputPath, "/datadensity-records-per-person.csv"))  
  
    # data density - concepts  per person
    renderedSql <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/datadensity/conceptsperperson.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema
    )  
    conceptsPerPerson <- DatabaseConnector::querySql(conn,renderedSql)
    data.table::fwrite(conceptsPerPerson, file=paste0(sourceOutputPath, "/datadensity-concepts-per-person.csv"))
    
    # data density - domains per person
    renderedSql <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/datadensity/domainsperperson.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema
    )  
    domainsPerPerson <- DatabaseConnector::querySql(conn,renderedSql)
    domainsPerPerson$PERCENT_VALUE <- round(as.numeric(domainsPerPerson$PERCENT_VALUE),2)
    data.table::fwrite(domainsPerPerson, file=paste0(sourceOutputPath, "/datadensity-domains-per-person.csv"))    
  }
  
  if (length(reports) == 0  || (length(reports) > 0 && ("domain" %in% reports || "concept" %in% reports))) {
    # metadata 
    generateAOMetadataReport(connectionDetails, cdmDatabaseSchema, sourceOutputPath)
    
    # cdm source
    generateAOCdmSourceReport(connectionDetails, cdmDatabaseSchema, sourceOutputPath)
    
    # domain summary - observation period
    generateAOObservationPeriodReport(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)   
    
    # death report
    generateAODeathReport(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)   
    
    # domain summary - conditions
    queryConditions <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/condition/sqlConditionTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataConditions <- DatabaseConnector::querySql(conn,queryConditions)   
    dataConditions$PERCENT_PERSONS <- format(round(dataConditions$PERCENT_PERSONS,4), nsmall=4)
    dataConditions$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataConditions$PERCENT_PERSONS),10)
    dataConditions$RECORDS_PER_PERSON <- format(round(dataConditions$RECORDS_PER_PERSON,1),nsmall=1)
    dataConditions$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataConditions$RECORDS_PER_PERSON),10)
    data.table::fwrite(dataConditions, file=paste0(sourceOutputPath, "/domain-summary-condition_occurrence.csv"))  
    
    # domain summary - condition eras
    queryConditionEra <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/conditionera/sqlConditionEraTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataConditionEra <- DatabaseConnector::querySql(conn,queryConditionEra)   
    dataConditionEra$PERCENT_PERSONS <- format(round(dataConditionEra$PERCENT_PERSONS,4), nsmall=4)
    dataConditionEra$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataConditionEra$PERCENT_PERSONS),10)
    dataConditionEra$RECORDS_PER_PERSON <- format(round(dataConditionEra$RECORDS_PER_PERSON,1),nsmall=1)
    dataConditionEra$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataConditionEra$RECORDS_PER_PERSON),10)
    data.table::fwrite(dataConditionEra, file=paste0(sourceOutputPath, "/domain-summary-condition_era.csv"))     
    
    # domain summary - drugs
    queryDrugs <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/drug/sqlDrugTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )
    dataDrugs <- DatabaseConnector::querySql(conn,queryDrugs)   
    dataDrugs$PERCENT_PERSONS <- format(round(dataDrugs$PERCENT_PERSONS,4), nsmall=4)
    dataDrugs$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataDrugs$PERCENT_PERSONS),10)
    dataDrugs$RECORDS_PER_PERSON <- format(round(dataDrugs$RECORDS_PER_PERSON,1),nsmall=1)
    dataDrugs$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataDrugs$RECORDS_PER_PERSON),10)
    data.table::fwrite(dataDrugs, file=paste0(sourceOutputPath, "/domain-summary-drug_exposure.csv"))    
    
    # domain summary - drug era
    queryDrugEra <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/drugera/sqlDrugEraTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )
    dataDrugEra <- DatabaseConnector::querySql(conn,queryDrugEra)   
    dataDrugEra$PERCENT_PERSONS <- format(round(dataDrugEra$PERCENT_PERSONS,4), nsmall=4)
    dataDrugEra$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataDrugEra$PERCENT_PERSONS),10)
    dataDrugEra$RECORDS_PER_PERSON <- format(round(dataDrugEra$RECORDS_PER_PERSON,1),nsmall=1)
    dataDrugEra$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataDrugEra$RECORDS_PER_PERSON), 10)
    data.table::fwrite(dataDrugEra, file=paste0(sourceOutputPath, "/domain-summary-drug_era.csv"))       
    
    # domain summary - measurements
    queryMeasurements <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/measurement/sqlMeasurementTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  	
	dataMeasurements <- DatabaseConnector::querySql(conn,queryMeasurements)	
    dataMeasurements$PERCENT_PERSONS <- format(round(dataMeasurements$PERCENT_PERSONS,4), nsmall=4)
    dataMeasurements$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataMeasurements$PERCENT_PERSONS), 10)
    dataMeasurements$RECORDS_PER_PERSON <- format(round(dataMeasurements$RECORDS_PER_PERSON,1),nsmall=1)
    dataMeasurements$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataMeasurements$RECORDS_PER_PERSON), 10)
	dataMeasurements$PERCENT_MISSING_VALUES <- format(round(dataMeasurements$PERCENT_MISSING_VALUES,4), nsmall=4)

    data.table::fwrite(dataMeasurements, file=paste0(sourceOutputPath, "/domain-summary-measurement.csv"))   
    
    # domain summary - observations
    queryObservations <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/observation/sqlObservationTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataObservations <- DatabaseConnector::querySql(conn,queryObservations)   
    dataObservations$PERCENT_PERSONS <- format(round(dataObservations$PERCENT_PERSONS,4), nsmall=4)
    dataObservations$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataObservations$PERCENT_PERSONS), 10)
    dataObservations$RECORDS_PER_PERSON <- format(round(dataObservations$RECORDS_PER_PERSON,1),nsmall=1)
    dataObservations$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataObservations$RECORDS_PER_PERSON), 10)
    data.table::fwrite(dataObservations, file=paste0(sourceOutputPath, "/domain-summary-observation.csv"))      
    
    # domain summary - visit details
    queryVisitDetails <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/visitdetail/sqlVisitDetailTreemapAO.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataVisitDetails <- DatabaseConnector::querySql(conn,queryVisitDetails)   
    dataVisitDetails$PERCENT_PERSONS <- format(round(dataVisitDetails$PERCENT_PERSONS,4), nsmall=4)
    dataVisitDetails$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataVisitDetails$PERCENT_PERSONS),10)
    dataVisitDetails$RECORDS_PER_PERSON <- format(round(dataVisitDetails$RECORDS_PER_PERSON,1),nsmall=1)
    dataVisitDetails$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataVisitDetails$RECORDS_PER_PERSON),10)
    dataVisitDetails$AVERAGE_DURATION <- format(round(dataVisitDetails$AVERAGE_DURATION,1),nsmall=1)
    names(dataVisitDetails)[names(dataVisitDetails) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
    data.table::fwrite(dataVisitDetails, file=paste0(sourceOutputPath, "/domain-summary-visit_detail.csv"))      
    
    # domain summary - visits
    queryVisits <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/visit/sqlVisitTreemapAO.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataVisits <- DatabaseConnector::querySql(conn,queryVisits)   
    dataVisits$PERCENT_PERSONS <- format(round(dataVisits$PERCENT_PERSONS,4), nsmall=4)
    dataVisits$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataVisits$PERCENT_PERSONS),10)
    dataVisits$RECORDS_PER_PERSON <- format(round(dataVisits$RECORDS_PER_PERSON,1),nsmall=1)
    dataVisits$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataVisits$RECORDS_PER_PERSON),10)
    dataVisits$AVERAGE_DURATION <- format(round(dataVisits$AVERAGE_DURATION,1),nsmall=1)
    names(dataVisits)[names(dataVisits) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
    data.table::fwrite(dataVisits, file=paste0(sourceOutputPath, "/domain-summary-visit_occurrence.csv"))   
    
    # domain stratification by visit concept
    queryVisits <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/visit/sqlDomainVisitStratification.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataVisits <- DatabaseConnector::querySql(conn,queryVisits)   
    data.table::fwrite(dataVisits, file=paste0(sourceOutputPath, "/domain-visit-stratification.csv"))      

    # domain summary - procedures
    queryProcedures <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/procedure/sqlProcedureTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )  
    dataProcedures <- DatabaseConnector::querySql(conn,queryProcedures)   
    dataProcedures$PERCENT_PERSONS <- format(round(dataProcedures$PERCENT_PERSONS,4), nsmall=4)
    dataProcedures$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataProcedures$PERCENT_PERSONS),10)
    dataProcedures$RECORDS_PER_PERSON <- format(round(dataProcedures$RECORDS_PER_PERSON,1),nsmall=1)
    dataProcedures$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataProcedures$RECORDS_PER_PERSON),10)
    data.table::fwrite(dataProcedures, file=paste0(sourceOutputPath, "/domain-summary-procedure_occurrence.csv"))   
    
    # domain summary - devices
    queryDevices <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/device/sqlDeviceTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema,
      vocab_database_schema = vocabDatabaseSchema
    )
    dataDevices <- DatabaseConnector::querySql(conn,queryDevices)   
    dataDevices$PERCENT_PERSONS <- format(round(dataDevices$PERCENT_PERSONS,4), nsmall=4)
    dataDevices$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataDevices$PERCENT_PERSONS),10)
    dataDevices$RECORDS_PER_PERSON <- format(round(dataDevices$RECORDS_PER_PERSON,1),nsmall=1)
    dataDevices$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataDevices$RECORDS_PER_PERSON),10)
    data.table::fwrite(dataDevices, file=paste0(sourceOutputPath, "/domain-summary-device_exposure.csv"))    
  }
  
  if (length(reports) == 0  || (length(reports) > 0 && "quality" %in% reports)) {
    # quality - completeness
    queryCompleteness <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/quality/sqlCompletenessTable.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      results_database_schema = resultsDatabaseSchema
    )  
    dataCompleteness <- DatabaseConnector::querySql(conn,queryCompleteness)   
    data.table::fwrite(dataCompleteness, file=paste0(sourceOutputPath, "/quality-completeness.csv"))   
  }

  if (length(reports) == 0  || (length(reports) > 0 && "performance" %in% reports)) {      
    generateAOAchillesPerformanceReport(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
  }
  
  if (length(reports) == 0  || (length(reports) > 0 && "concept" %in% reports)) {  
    # concept level reporting
    conceptsFolder <- file.path(sourceOutputPath,"concepts")
    dir.create(conceptsFolder,showWarnings = F)
    generateAOVisitReports(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAOVisitDetailReports(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)    
    generateAOMeasurementReports(connectionDetails, dataMeasurements, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAOConditionReports(connectionDetails, dataConditions, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAOConditionEraReports(connectionDetails, dataConditionEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAODrugReports(connectionDetails, dataDrugs, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAODeviceReports(connectionDetails, dataDevices, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)    
    generateAODrugEraReports(connectionDetails, dataDrugEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAOProcedureReports(connectionDetails, dataProcedures, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    generateAOObservationReports(connectionDetails, dataObservations, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)    
  }
  
  if (length(reports) == 0  || (length(reports) > 0 && "person" %in% reports)) {
    generateAOPersonReport(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
  }
}

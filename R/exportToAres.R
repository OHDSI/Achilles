normalizeEmptyValue <- function(x) {
  if (is.null(x) ||
    is.na(x) ||
    "NA" == x ||
    "NULL" == x) {
    character()
  } else {
    x
  }
}

createConceptMedatataTable <- function(report, concept_id, domain) {
  df <- data.frame(
    CONCEPT_ID = concept_id,
    CONCEPT_NAME = ifelse(length(report$CONCEPT_NAME) == 0, NA, report$CONCEPT_NAME),
    DOMAIN = domain,
    NUM_PERSONS = ifelse(length(report$NUM_PERSONS) == 0, NA, report$NUM_PERSONS),
    PERCENT_PERSONS = ifelse(length(report$PERCENT_PERSONS) == 0, NA, report$PERCENT_PERSONS),
    RECORDS_PER_PERSON = ifelse(length(report$RECORDS_PER_PERSON) == 0, NA, report$RECORDS_PER_PERSON)
  )
  return(df)
}

createConceptDataTable <- function(table, concept_id, domain) {
  df <- data.frame(table)
  df['CONCEPT_ID'] = concept_id
  df['DOMAIN'] = domain
  return(df)
}

writeReportToTable <- function(duckdbCon, report, tableName, schema) {

  if (nrow(report) > 0) {
    dbWriteTable(duckdbCon, DBI::Id(schema = schema, table = tableName), report, append = TRUE)
  }
}

exportDataToDuckDB <- function(data, duckdbCon = NULL, tableNames = NULL, concept_id = NULL, domain = NULL, schema = NULL) {
  if (!is.null(duckdbCon) &&
    !is.null(tableNames) &&
    !is.null(concept_id)) {
    if (length(data) != length(tableNames)) {
      cat("Number of reports and tableNames should match.\n")
      return()
    }
    for (i in seq_along(data)) {
      if (nrow(data[[i]]) > 0) {
        writeReportToTable(duckdbCon, createConceptDataTable(data[[i]], concept_id, domain), tableNames[[i]], schema)
      }
    }
  } else {
    cat("Missing required parameters for DuckDB export.\n")
  }
}

processAndExportConceptData <- function(concept_id, duckdbCon, reports, outputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, domain, schema) {
  report <- reports[reports$CONCEPT_ID == concept_id,]
  report <- as.list(report)

  tableNames <- lapply(columnsToConvertToDataFrame, tolower)

  #Normalize the specified columns
  for (col in columnsToNormalize) {
    report[[col]] <- normalizeEmptyValue(report[[col]])
  }

  # Convert specified columns to data frames
  for (col in columnsToConvertToDataFrame) {
    report[[col]] <- as.data.frame(report[[col]])
  }


  if (outputFormat == "json") {
    dir.create(paste0(outputPath, dir), recursive = T, showWarnings = F)
    filename <- paste(outputPath, dir, "/concept_", report$CONCEPT_ID, ".json", sep = '')
    write(jsonlite::toJSON(report), filename)

  }
  else if (outputFormat == "duckdb") {
    metadata <- createConceptMedatataTable(report, concept_id, domain)
    dbWriteTable(duckdbCon, DBI::Id(schema = schema, table = "concept_metadata"), metadata, append = TRUE)
    tableList <- lapply(columnsToConvertToDataFrame, function(col) report[[col]])
    exportDataToDuckDB(tableList, duckdbCon, tableNames, concept_id, domain, schema)
  }
}


generateAOProcedureReports <- function(connectionDetails, proceduresData, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataProceduresByType <- DatabaseConnector::querySql(conn, queryProceduresByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)
  dataProcedureFrequencyDistribution <- DatabaseConnector::querySql(conn, queryProcedureFrequencyDistribution)

  if (nrow(proceduresData) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(proceduresData$CONCEPT_ID),
    CDM_TABLE_NAME = "PROCEDURE_OCCURRENCE"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        proceduresData,
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "CDM_TABLE_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON") %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataProcedureFrequencyDistribution %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PROCEDURE_FREQUENCY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataProceduresByType %>%
            dplyr::select(c(1, 4, 5)) %>%
            tidyr::nest(PROCEDURES_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "PROCEDURE_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstOccurrence %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_OCCURRENCE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()

  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAOPersonReport <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  output = { }
  conn <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection = conn))
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/person/population.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    warnOnMissingParameters = FALSE,
    cdm_database_schema = cdmDatabaseSchema,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )

  personSummaryData <- DatabaseConnector::querySql(conn, renderedSql)
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
  ageGenderData <- DatabaseConnector::querySql(conn, renderedSql)
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
  genderData <- DatabaseConnector::querySql(conn, renderedSql)
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
  raceData <- DatabaseConnector::querySql(conn, renderedSql)
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
  ethnicityData <- DatabaseConnector::querySql(conn, renderedSql)
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
  birthYearData <- DatabaseConnector::querySql(conn, renderedSql)
  output$BIRTH_YEAR_DATA <- birthYearData
  return(output)
}

generateAOAchillesPerformanceReport <- function(connection, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{

  queryAchillesPerformance <- SqlRender::loadRenderTranslateSql(sqlFilename = "export/performance/sqlAchillesPerformance.sql",
                                                                packageName = "Achilles",
                                                                dbms = connectionDetails$dbms,
                                                                warnOnMissingParameters = FALSE,
                                                                cdm_database_schema = cdmDatabaseSchema,
                                                                results_database_schema = resultsDatabaseSchema,
                                                                vocab_database_schema = vocabDatabaseSchema
  )

  dataPerformance <- DatabaseConnector::querySql(connection, queryAchillesPerformance)
  names(dataPerformance) <- c("analysis_id", "analysis_name", "category", "elapsed_seconds")
  dataPerformance$elapsed_seconds <- format(round(as.numeric(dataPerformance$elapsed_seconds), digits = 2), nsmall = 2)
  return(dataPerformance)
}

generateAODeathReport <- function(connection, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{

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
  deathByTypeData <- DatabaseConnector::querySql(connection, queryDeathByType)
  prevalenceByGenderAgeYearData <- DatabaseConnector::querySql(connection, queryPrevalenceByGenderAgeYear)
  prevalenceByMonthData <- DatabaseConnector::querySql(connection, queryPrevalenceByMonth)
  ageAtDeathData <- DatabaseConnector::querySql(connection, queryAgeAtDeath)

  output = { }
  output$PREVALENCE_BY_GENDER_AGE_YEAR = prevalenceByGenderAgeYearData
  output$PREVALENCE_BY_MONTH = prevalenceByMonthData
  output$DEATH_BY_TYPE = deathByTypeData
  output$AGE_AT_DEATH = ageAtDeathData
  return(output)
}

generateAOObservationPeriodReport <- function(connection, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
  output = { }
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/ageatfirst.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  ageAtFirstObservationData <- DatabaseConnector::querySql(connection, renderedSql)
  output$AGE_AT_FIRST_OBSERVATION <- ageAtFirstObservationData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/agebygender.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  ageByGenderData <- DatabaseConnector::querySql(connection, renderedSql)
  output$AGE_BY_GENDER = ageByGenderData

  observationLengthHist <- { }
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observationlength_stats.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observationLengthStats <- DatabaseConnector::querySql(connection, renderedSql)
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
  observationLengthData <- DatabaseConnector::querySql(connection, renderedSql)
  output$OBSERVATION_LENGTH_HISTOGRAM = observationLengthHist

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/cumulativeduration.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  cumulativeDurationData <- DatabaseConnector::querySql(connection, renderedSql)
  cumulativeDurationData$X_LENGTH_OF_OBSERVATION <- cumulativeDurationData$X_LENGTH_OF_OBSERVATION / 365.25
  cumulativeDurationData$SERIES_NAME <- NULL
  names(cumulativeDurationData) <- c("YEARS", "PERCENT_PEOPLE")
  output$CUMULATIVE_DURATION = cumulativeDurationData

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observationlengthbygender.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  opLengthByGenderData <- DatabaseConnector::querySql(connection, renderedSql)
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
  opLengthByAgeData <- DatabaseConnector::querySql(connection, renderedSql)
  opLengthByAgeData$MIN_VALUE <- opLengthByAgeData$MIN_VALUE / 365.25
  opLengthByAgeData$P10_VALUE <- opLengthByAgeData$P10_VALUE / 365.25
  opLengthByAgeData$P25_VALUE <- opLengthByAgeData$P25_VALUE / 365.25
  opLengthByAgeData$MEDIAN_VALUE <- opLengthByAgeData$MEDIAN_VALUE / 365.25
  opLengthByAgeData$P75_VALUE <- opLengthByAgeData$P75_VALUE / 365.25
  opLengthByAgeData$P90_VALUE <- opLengthByAgeData$P90_VALUE / 365.25
  opLengthByAgeData$MAX_VALUE <- opLengthByAgeData$MAX_VALUE / 365.25
  output$OBSERVATION_PERIOD_LENGTH_BY_AGE = opLengthByAgeData

  observedByYearHist <- { }
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observedbyyear_stats.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observedByYearStats <- DatabaseConnector::querySql(connection, renderedSql)
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
  observedByYearData <- DatabaseConnector::querySql(connection, renderedSql)
  observedByYearHist$DATA <- observedByYearData
  output$OBSERVED_BY_YEAR_HISTOGRAM = observedByYearHist

  observedByMonth <- { }
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/observedbymonth.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  observedByMonth <- DatabaseConnector::querySql(connection, renderedSql)
  output$OBSERVED_BY_MONTH = observedByMonth

  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observationperiod/periodsperperson.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  personPeriodsData <- DatabaseConnector::querySql(connection, renderedSql)
  output$PERSON_PERIODS_DATA = personPeriodsData
  return(output)
}

generateAOVisitReports <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{

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
  dataVisits <- DatabaseConnector::querySql(conn, queryVisits)
  names(dataVisits)[names(dataVisits) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataVisitDurationByType <- DatabaseConnector::querySql(conn, queryVisitDurationByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)

  if (nrow(dataVisits) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataVisits$CONCEPT_ID),
    CDM_TABLE_NAME = "VISIT_OCCURRENCE"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataVisits %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataVisitDurationByType %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(VISIT_DURATION_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstOccurrence %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_OCCURRENCE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAOVisitDetailReports <- function(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataVisitDetails <- DatabaseConnector::querySql(conn, queryVisitDetails)
  names(dataVisitDetails)[names(dataVisitDetails) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataVisitDetailDurationByType <- DatabaseConnector::querySql(conn, queryVisitDetailDurationByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)

  if (nrow(dataVisitDetails) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataVisitDetails$CONCEPT_ID),
    CDM_TABLE_NAME = "VISIT_DETAIL"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataVisitDetails %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataVisitDetailDurationByType %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(VISIT_DETAIL_DURATION_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstOccurrence %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_OCCURRENCE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAOMetadataReport <- function(connection, cdmDatabaseSchema, outputPath)
{
  if (DatabaseConnector::existsTable(connection = connection, databaseSchema = cdmDatabaseSchema, tableName = "METADATA"))
  {
    queryMetadata <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/metadata/sqlMetadata.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      cdm_database_schema = cdmDatabaseSchema
    )
    dataMetadata <- DatabaseConnector::querySql(connection, queryMetadata)
    return(dataMetadata)
  }
}

generateAOObservationReports <- function(connectionDetails, observationsData, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataObservationsByType <- DatabaseConnector::querySql(conn, queryObservationsByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)
  dataObsFrequencyDistribution <- DatabaseConnector::querySql(conn, queryObsFrequencyDistribution)

  if (nrow(observationsData) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(observationsData$CONCEPT_ID),
    CDM_TABLE_NAME = "OBSERVATION"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        observationsData,
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "CDM_TABLE_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON") %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataObsFrequencyDistribution %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(OBS_FREQUENCY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataObservationsByType %>%
            dplyr::select(c(1, 4, 5)) %>%
            tidyr::nest(OBSERVATIONS_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "OBSERVATION_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstOccurrence %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_OCCURRENCE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAOCdmSourceReport <- function(connection, cdmDatabaseSchema, outputPath)
{
  if (DatabaseConnector::existsTable(connection = connection, databaseSchema = cdmDatabaseSchema, tableName = "CDM_SOURCE"))
  {
    queryCdmSource <- SqlRender::loadRenderTranslateSql(
      sqlFilename = "export/metadata/sqlCdmSource.sql",
      packageName = "Achilles",
      dbms = connectionDetails$dbms,
      cdm_database_schema = cdmDatabaseSchema
    )

    dataCdmSource <- DatabaseConnector::querySql(connection, queryCdmSource)
    return(dataCdmSource)
  }
}

generateAODashboardReport <- function(outputPath)
{
  output <- { }
  personReport <- jsonlite::fromJSON(file = paste(outputPath, "/person.json", sep = ""))
  output$SUMMARY <- personReport$SUMMARY
  output$GENDER_DATA <- personReport$GENDER_DATA
  opReport <- jsonlite::fromJSON(file = paste(outputPath, "/observationperiod.json", sep = ""))

  output$AGE_AT_FIRST_OBSERVATION_HISTOGRAM <- opReport$AGE_AT_FIRST_OBSERVATION_HISTOGRAM
  output$CUMULATIVE_DURATION <- opReport$CUMULATIVE_DURATION
  output$OBSERVED_BY_MONTH <- opReport$OBSERVED_BY_MONTH

  jsonOutput <- jsonlite::toJSON(output)
  write(jsonOutput, file = paste(outputPath, "/dashboard.json", sep = ""))
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataMeasurementsByType <- DatabaseConnector::querySql(conn, queryMeasurementsByType)
  dataAgeAtFirstOccurrence <- DatabaseConnector::querySql(conn, queryAgeAtFirstOccurrence)
  dataRecordsByUnit <- DatabaseConnector::querySql(conn, queryRecordsByUnit)
  dataMeasurementValueDistribution <- DatabaseConnector::querySql(conn, queryMeasurementValueDistribution)
  dataLowerLimitDistribution <- DatabaseConnector::querySql(conn, queryLowerLimitDistribution)
  dataUpperLimitDistribution <- DatabaseConnector::querySql(conn, queryUpperLimitDistribution)
  dataValuesRelativeToNorm <- DatabaseConnector::querySql(conn, queryValuesRelativeToNorm)
  dataFrequencyDistribution <- DatabaseConnector::querySql(conn, queryFrequencyDistribution)

  if (nrow(dataPrevalenceByMonth) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataPrevalenceByMonth$CONCEPT_ID),
    CDM_TABLE_NAME = "MEASUREMENT"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataMeasurements %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataFrequencyDistribution %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(FREQUENCY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataMeasurementsByType %>%
            dplyr::select(c(1, 4, 5)) %>%
            tidyr::nest(MEASUREMENTS_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "MEASUREMENT_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstOccurrence %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_OCCURRENCE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataRecordsByUnit %>%
            dplyr::select(c(1, 4, 5)) %>%
            tidyr::nest(RECORDS_BY_UNIT = c(-1))
        ),
        by = c("CONCEPT_ID" = "MEASUREMENT_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataMeasurementValueDistribution %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(MEASUREMENT_VALUE_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataLowerLimitDistribution %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(LOWER_LIMIT_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataUpperLimitDistribution %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(UPPER_LIMIT_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataValuesRelativeToNorm %>%
            dplyr::select(c(1, 4, 5)) %>%
            tidyr::nest(VALUES_RELATIVE_TO_NORM = c(-1))
        ),
        by = c("CONCEPT_ID" = "MEASUREMENT_CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAODrugEraReports <- function(connectionDetails, dataDrugEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{

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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn, queryAgeAtFirstExposure)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataLengthOfEra <- DatabaseConnector::querySql(conn, queryLengthOfEra)

  if (nrow(dataDrugEra) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataDrugEra$CONCEPT_ID),
    CDM_TABLE_NAME = "DRUG_ERA"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataDrugEra %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstExposure %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_EXPOSURE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 2, 3, 4, 5)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 2, 3)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataLengthOfEra %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(LENGTH_OF_ERA = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAODrugReports <- function(connectionDetails, dataDrugs, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{

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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn, queryAgeAtFirstExposure)
  dataDaysSupplyDistribution <- DatabaseConnector::querySql(conn, queryDaysSupplyDistribution)
  dataDrugsByType <- DatabaseConnector::querySql(conn, queryDrugsByType)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataQuantityDistribution <- DatabaseConnector::querySql(conn, queryQuantityDistribution)
  dataRefillsDistribution <- DatabaseConnector::querySql(conn, queryRefillsDistribution)
  dataDrugFrequencyDistribution <- DatabaseConnector::querySql(conn, queryDrugFrequencyDistribution)

  if (nrow(dataPrevalenceByMonth) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataPrevalenceByMonth$CONCEPT_ID),
    CDM_TABLE_NAME = "DRUG_EXPOSURE"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataDrugs %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstExposure %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_EXPOSURE = c(-1))
        ),
        by = c("CONCEPT_ID" = "DRUG_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataDaysSupplyDistribution %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(DAYS_SUPPLY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "DRUG_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataDrugsByType %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(DRUGS_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "DRUG_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataDrugFrequencyDistribution %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(DRUG_FREQUENCY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataQuantityDistribution %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(QUANTITY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "DRUG_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataRefillsDistribution %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(REFILLS_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "DRUG_CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAODeviceReports <- function(connectionDetails, dataDevices, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataAgeAtFirstExposure <- DatabaseConnector::querySql(conn, queryAgeAtFirstExposure)
  dataDevicesByType <- DatabaseConnector::querySql(conn, queryDevicesByType)
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataDeviceFrequencyDistribution <- DatabaseConnector::querySql(conn, queryDeviceFrequencyDistribution)

  if (nrow(dataDevices) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataDevices$CONCEPT_ID),
    CDM_TABLE_NAME = "DEVICE_EXPOSURE"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataDevices %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstExposure %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_EXPOSURE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataDevicesByType %>%
            dplyr::select(c(1, 4, 5)) %>%
            tidyr::nest(DEVICES_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "DEVICE_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataDeviceFrequencyDistribution %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(DEVICE_FREQUENCY_DISTRIBUTION = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAOConditionReports <- function(connectionDetails, duckdbCon, dataConditions, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataConditionsByType <- DatabaseConnector::querySql(conn, queryConditionsByType)
  dataAgeAtFirstDiagnosis <- DatabaseConnector::querySql(conn, queryAgeAtFirstDiagnosis)

  if (nrow(dataPrevalenceByMonth) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataPrevalenceByMonth$CONCEPT_ID),
    CDM_TABLE_NAME = "CONDITION_OCCURRENCE"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataConditions %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 3, 4, 5, 6)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 3, 4)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataConditionsByType %>%
            dplyr::select(c(1, 2, 3)) %>%
            tidyr::nest(CONDITIONS_BY_TYPE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONDITION_CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstDiagnosis %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_DIAGNOSIS = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}

generateAOConditionEraReports <- function(connectionDetails, dataConditionEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, outputPath)
{
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
  on.exit(DatabaseConnector::disconnect(connection = conn))
  dataPrevalenceByGenderAgeYear <- DatabaseConnector::querySql(conn, queryPrevalenceByGenderAgeYear)
  dataPrevalenceByMonth <- DatabaseConnector::querySql(conn, queryPrevalenceByMonth)
  dataLengthOfEra <- DatabaseConnector::querySql(conn, queryLengthOfEra)
  dataAgeAtFirstDiagnosis <- DatabaseConnector::querySql(conn, queryAgeAtFirstDiagnosis)

  if (nrow(dataConditionEra) == 0) {
    return()
  }
  uniqueConcepts <- data.frame(
    CONCEPT_ID = unique(dataConditionEra$CONCEPT_ID),
    CDM_TABLE_NAME = "CONDITION_ERA"
  )
  reports <-
    uniqueConcepts %>%
      dplyr::left_join(
        (
          dataConditionEra %>%
            dplyr::select("CONCEPT_ID", "CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataAgeAtFirstDiagnosis %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(AGE_AT_FIRST_EXPOSURE = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByGenderAgeYear %>%
            dplyr::select(c(1, 2, 3, 4, 5)) %>%
            tidyr::nest(PREVALENCE_BY_GENDER_AGE_YEAR = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataPrevalenceByMonth %>%
            dplyr::select(c(1, 2, 3)) %>%
            tidyr::nest(PREVALENCE_BY_MONTH = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::left_join(
        (
          dataLengthOfEra %>%
            dplyr::select(c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
            tidyr::nest(LENGTH_OF_ERA = c(-1))
        ),
        by = c("CONCEPT_ID" = "CONCEPT_ID")
      ) %>%
      dplyr::collect()
  return(list("reports" = reports, "uniqueConcepts" = uniqueConcepts))
}


generateDataDensityTotal <- function(connection, resultsDatabaseSchema) {
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/datadensity/totalrecords.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )

  totalRecordsData <- DatabaseConnector::querySql(connection, renderedSql)
  colnames(totalRecordsData) <- c("domain", "date", "records")
  totalRecordsData$date <- lubridate::parse_date_time(totalRecordsData$date, "ym")

  domainAggregates <- aggregate(totalRecordsData$records, by = list(domain = totalRecordsData$domain), FUN = sum)
  names(domainAggregates) <- c("domain", "count_records")
  data <- list("totalRecordsData" = totalRecordsData, "domainAggregates" = domainAggregates)
  return(data)
}

generateDataDensityRecordsPerPerson <- function(connection, resultsDatabaseSchema) {
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/datadensity/recordsperperson.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )

  recordsPerPerson <- DatabaseConnector::querySql(connection, renderedSql)
  colnames(recordsPerPerson) <- c("domain", "date", "records")
  recordsPerPerson$date <- lubridate::parse_date_time(recordsPerPerson$date, "ym")
  recordsPerPerson$records <- round(recordsPerPerson$records, 2)
  return(recordsPerPerson)
}

generateDataDensityConceptsPerPerson <- function(connection, resultsDatabaseSchema) {
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/datadensity/conceptsperperson.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  conceptsPerPerson <- DatabaseConnector::querySql(connection, renderedSql)
  return(conceptsPerPerson)
  #data.table::fwrite(conceptsPerPerson, file=paste0(sourceOutputPath, "/datadensity-concepts-per-person.csv"))
  #dbWriteTable(duckdbCon, "concepts_per_person", conceptsPerPerson)
}

generateDataDensityDomainsPerPerson <- function(connection, resultsDatabaseSchema) {
  renderedSql <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/datadensity/domainsperperson.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  domainsPerPerson <- DatabaseConnector::querySql(connection, renderedSql)
  domainsPerPerson$PERCENT_VALUE <- round(as.numeric(domainsPerPerson$PERCENT_VALUE), 2)
  return(domainsPerPerson)
  #data.table::fwrite(domainsPerPerson, file=paste0(sourceOutputPath, "/datadensity-domains-per-person.csv"))
  #dbWriteTable(duckdbCon, "domains_per_person", domainsPerPerson)
}

generateDomainSummaryConditions <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryConditions <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/condition/sqlConditionTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataConditions <- DatabaseConnector::querySql(connection, queryConditions)
  dataConditions$PERCENT_PERSONS <- format(round(dataConditions$PERCENT_PERSONS, 4), nsmall = 4)
  dataConditions$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataConditions$PERCENT_PERSONS), 10)
  dataConditions$RECORDS_PER_PERSON <- format(round(dataConditions$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataConditions$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataConditions$RECORDS_PER_PERSON), 10)
  return(dataConditions)
  #data.table::fwrite(dataConditions, file=paste0(sourceOutputPath, "/domain-summary-condition_occurrence.csv"))
  #dbWriteTable(duckdbCon, "domain_summary", dataConditions, append = TRUE)
}

generateDomainSummaryConditionEras <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryConditionEra <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/conditionera/sqlConditionEraTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataConditionEra <- DatabaseConnector::querySql(connection, queryConditionEra)
  dataConditionEra$PERCENT_PERSONS <- format(round(dataConditionEra$PERCENT_PERSONS, 4), nsmall = 4)
  dataConditionEra$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataConditionEra$PERCENT_PERSONS), 10)
  dataConditionEra$RECORDS_PER_PERSON <- format(round(dataConditionEra$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataConditionEra$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataConditionEra$RECORDS_PER_PERSON), 10)
  return(dataConditionEra)
  #data.table::fwrite(dataConditionEra, file=paste0(sourceOutputPath, "/domain-summary-condition_era.csv"))
}

generateDomainSummaryDrugs <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryDrugs <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlDrugTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataDrugs <- DatabaseConnector::querySql(connection, queryDrugs)
  dataDrugs$PERCENT_PERSONS <- format(round(dataDrugs$PERCENT_PERSONS, 4), nsmall = 4)
  dataDrugs$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataDrugs$PERCENT_PERSONS), 10)
  dataDrugs$RECORDS_PER_PERSON <- format(round(dataDrugs$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataDrugs$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataDrugs$RECORDS_PER_PERSON), 10)
  return(dataDrugs)
  #data.table::fwrite(dataDrugs, file=paste0(sourceOutputPath, "/domain-summary-drug_exposure.csv"))
}

generateDomainDrugStratification <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryDrugType <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drug/sqlDomainDrugStratification.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataDrugType <- DatabaseConnector::querySql(connection, queryDrugType)
  return(dataDrugType)
  #data.table::fwrite(dataDrugType, file=paste0(sourceOutputPath, "/domain-drug-stratification.csv"))
}

generateDomainSummaryDrugEra <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryDrugEra <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/drugera/sqlDrugEraTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataDrugEra <- DatabaseConnector::querySql(connection, queryDrugEra)
  dataDrugEra$PERCENT_PERSONS <- format(round(dataDrugEra$PERCENT_PERSONS, 4), nsmall = 4)
  dataDrugEra$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataDrugEra$PERCENT_PERSONS), 10)
  dataDrugEra$RECORDS_PER_PERSON <- format(round(dataDrugEra$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataDrugEra$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataDrugEra$RECORDS_PER_PERSON), 10)
  return(dataDrugEra)
  #data.table::fwrite(dataDrugEra, file=paste0(sourceOutputPath, "/domain-summary-drug_era.csv"))
}

generateDomainSummaryMeasurements <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryMeasurements <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/measurement/sqlMeasurementTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataMeasurements <- DatabaseConnector::querySql(connection, queryMeasurements)
  dataMeasurements$PERCENT_PERSONS <- format(round(dataMeasurements$PERCENT_PERSONS, 4), nsmall = 4)
  dataMeasurements$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataMeasurements$PERCENT_PERSONS), 10)
  dataMeasurements$RECORDS_PER_PERSON <- format(round(dataMeasurements$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataMeasurements$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataMeasurements$RECORDS_PER_PERSON), 10)
  return(dataMeasurements)
  #data.table::fwrite(dataMeasurements, file=paste0(sourceOutputPath, "/domain-summary-measurement.csv"))
}

generateDomainSummaryObservations <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryObservations <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/observation/sqlObservationTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataObservations <- DatabaseConnector::querySql(connection, queryObservations)
  dataObservations$PERCENT_PERSONS <- format(round(dataObservations$PERCENT_PERSONS, 4), nsmall = 4)
  dataObservations$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataObservations$PERCENT_PERSONS), 10)
  dataObservations$RECORDS_PER_PERSON <- format(round(dataObservations$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataObservations$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataObservations$RECORDS_PER_PERSON), 10)
  return(dataObservations)
  #data.table::fwrite(dataObservations, file=paste0(sourceOutputPath, "/domain-summary-observation.csv"))
}

generateDomainSummaryVisitDetails <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryVisitDetails <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visitdetail/sqlVisitDetailTreemap.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataVisitDetails <- DatabaseConnector::querySql(connection, queryVisitDetails)
  dataVisitDetails$PERCENT_PERSONS <- format(round(dataVisitDetails$PERCENT_PERSONS, 4), nsmall = 4)
  dataVisitDetails$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataVisitDetails$PERCENT_PERSONS), 10)
  dataVisitDetails$RECORDS_PER_PERSON <- format(round(dataVisitDetails$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataVisitDetails$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataVisitDetails$RECORDS_PER_PERSON), 10)
  names(dataVisitDetails)[names(dataVisitDetails) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
  return(dataVisitDetails)
  #data.table::fwrite(dataVisitDetails, file=paste0(sourceOutputPath, "/domain-summary-visit_detail.csv"))
}

generateDomainSummaryVisits <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryVisits <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlVisitTreemap.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataVisits <- DatabaseConnector::querySql(connection, queryVisits)
  dataVisits$PERCENT_PERSONS <- format(round(dataVisits$PERCENT_PERSONS, 4), nsmall = 4)
  dataVisits$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataVisits$PERCENT_PERSONS), 10)
  dataVisits$RECORDS_PER_PERSON <- format(round(dataVisits$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataVisits$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataVisits$RECORDS_PER_PERSON), 10)
  names(dataVisits)[names(dataVisits) == 'CONCEPT_PATH'] <- 'CONCEPT_NAME'
  return(dataVisits)
  #data.table::fwrite(dataVisits, file=paste0(sourceOutputPath, "/domain-summary-visit_occurrence.csv"))
}

generateDomainVisitStratification <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryVisits <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/visit/sqlDomainVisitStratification.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataVisits <- DatabaseConnector::querySql(connection, queryVisits)
  return(dataVisits)
  #data.table::fwrite(dataVisits, file=paste0(sourceOutputPath, "/domain-visit-stratification.csv"))
}

generateDomainSummaryProcedures <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryProcedures <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/procedure/sqlProcedureTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataProcedures <- DatabaseConnector::querySql(connection, queryProcedures)
  dataProcedures$PERCENT_PERSONS <- format(round(dataProcedures$PERCENT_PERSONS, 4), nsmall = 4)
  dataProcedures$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataProcedures$PERCENT_PERSONS), 10)
  dataProcedures$RECORDS_PER_PERSON <- format(round(dataProcedures$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataProcedures$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataProcedures$RECORDS_PER_PERSON), 10)
  return(dataProcedures)
  #data.table::fwrite(dataProcedures, file=paste0(sourceOutputPath, "/domain-summary-procedure_occurrence.csv"))
}

generateDomainSummaryDevices <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryDevices <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/device/sqlDeviceTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  dataDevices <- DatabaseConnector::querySql(connection, queryDevices)
  dataDevices$PERCENT_PERSONS <- format(round(dataDevices$PERCENT_PERSONS, 4), nsmall = 4)
  dataDevices$PERCENT_PERSONS_NTILE <- dplyr::ntile(dplyr::desc(dataDevices$PERCENT_PERSONS), 10)
  dataDevices$RECORDS_PER_PERSON <- format(round(dataDevices$RECORDS_PER_PERSON, 1), nsmall = 1)
  dataDevices$RECORDS_PER_PERSON_NTILE <- dplyr::ntile(dplyr::desc(dataDevices$RECORDS_PER_PERSON), 10)
  return(dataDevices)
  #data.table::fwrite(dataDevices, file=paste0(sourceOutputPath, "/domain-summary-device_exposure.csv"))
}

generateDomainSummaryProvider <- function(connection, resultsDatabaseSchema, vocabDatabaseSchema) {
  queryProviders <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/provider/sqlProviderSpecialty.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema,
    vocab_database_schema = vocabDatabaseSchema
  )
  writeLines("Generating provider reports")
  dataProviders <- DatabaseConnector::querySql(connection, queryProviders)
  dataProviders$PERCENT_PERSONS <- format(round(dataProviders$PERCENT_PERSONS, 4), nsmall = 4)
  return(dataProviders)
  #data.table::fwrite(dataProviders, file=paste0(sourceOutputPath, "/domain-summary-provider.csv"))
  #dbWriteTable(duckdbCon, "domain_summary", dataProviders, append = TRUE)
}

generateQualityCompleteness <- function(connection, resultsDatabaseSchema) {
  queryCompleteness <- SqlRender::loadRenderTranslateSql(
    sqlFilename = "export/quality/sqlCompletenessTable.sql",
    packageName = "Achilles",
    dbms = connectionDetails$dbms,
    results_database_schema = resultsDatabaseSchema
  )
  dataCompleteness <- DatabaseConnector::querySql(connection, queryCompleteness)
  dataCompleteness <- dataCompleteness[order(-dataCompleteness$RECORD_COUNT),]
  # prevent downstream crashes with large files
  if (nrow(dataCompleteness) > 100000) {
    dataCompleteness <- dataCompleteness[1:100000,]
  }
  #data.table::fwrite(dataCompleteness, file=paste0(sourceOutputPath, "/quality-completeness.csv"))
  return(dataCompleteness)
}

#' @title exportToAres
#'
#' @description
#' \code{exportToAres} Exports Achilles statistics for ARES
#'
#' @details
#' Creates export files
#'
#' @param connectionDetails             An R object of type ConnectionDetail (details for the function that contains server info, database type, optionally username/password, port)
#' @param cdmDatabaseSchema             Name of the database schema that contains the OMOP CDM.
#' @param resultsDatabaseSchema     		Name of the database schema that contains the Achilles analysis files. Default is cdmDatabaseSchema
#' @param outputPath		                A folder location to save the JSON files. Default is current working folder
#' @param vocabDatabaseSchema		        string name of database schema that contains OMOP Vocabulary. Default is cdmDatabaseSchema. On SQL Server, this should specifiy both the database and the schema, so for example 'results.dbo'.
#' @param outputFormat                  default or alternatively "duckdb" to use parquet and duckdb formats.
#' @param reports                       vector of reports to run, c() defaults to all reports
#'
#' See \code{showReportTypes} for a list of all report types
#'
#' @return none
#'
#'@import DBI
#'@importFrom data.table fwrite
#'@importFrom dplyr ntile desc
#'@export
exportToAres <- function(
  connectionDetails,
  cdmDatabaseSchema,
  resultsDatabaseSchema,
  vocabDatabaseSchema,
  outputPath,
  outputFormat = "default",
  reports = c())
{
  conn <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection = conn))

  # generate a folder name for this release of the cdm characterization
  sql <- SqlRender::render(sql = "select * from @cdmDatabaseSchema.cdm_source;", cdmDatabaseSchema = cdmDatabaseSchema)
  sql <- SqlRender::translate(sql = sql, targetDialect = connectionDetails$dbms)
  metadata <- DatabaseConnector::querySql(conn, sql)
  sourceKey <- gsub(" ", "_", metadata$CDM_SOURCE_ABBREVIATION)
  releaseDateKey <- format(lubridate::ymd(metadata$CDM_RELEASE_DATE), "%Y%m%d")
  sourceOutputPath <- file.path(outputPath, sourceKey, releaseDateKey)
  dir.create(sourceOutputPath, showWarnings = F, recursive = T)
  duckdbCon <- NULL
  conceptsSchema <- "concepts"
  conceptsFolder <- file.path(sourceOutputPath, "concepts")
  dir.create(conceptsFolder, showWarnings = F)
  if (outputFormat == "duckdb") {
    conceptsDatabasePath <- file.path(conceptsFolder, 'data.duckdb')
    if (file.exists(conceptsDatabasePath)) {
      unlink(conceptsDatabasePath)
    }
    duckdbCon <- dbConnect(duckdb::duckdb(), dbdir = conceptsDatabasePath, read_only = FALSE)
    dbExecute(duckdbCon, paste("CREATE SCHEMA", conceptsSchema))
    on.exit(dbDisconnect(duckdbCon, shutdown = TRUE))
  }
  print(paste0("processing AO export to ", sourceOutputPath))

  if (length(reports) == 0 || (length(reports) > 0 && "density" %in% reports)) {
    writeLines("Generating data density reports")
    currentTable <- { }
    # data density - totals
    currentTable <- generateDataDensityTotal(conn, resultsDatabaseSchema)
    data.table::fwrite(currentTable$totalRecordsData, file = paste0(sourceOutputPath, "/datadensity-total.csv"))
    data.table::fwrite(currentTable$domainAggregates, file = paste0(sourceOutputPath, "/records-by-domain.csv"))

    # data density - records per person
    currentTable <- generateDataDensityRecordsPerPerson(conn, resultsDatabaseSchema)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/datadensity-records-per-person.csv"))

    # data density - concepts  per person
    currentTable <- generateDataDensityConceptsPerPerson(conn, resultsDatabaseSchema)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/datadensity-concepts-per-person.csv"))

    # data density - domains per person
    currentTable <- generateDataDensityDomainsPerPerson(conn, resultsDatabaseSchema)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/datadensity-domains-per-person.csv"))
  }

  if (length(reports) == 0 || (length(reports) > 0 && ("domain" %in% reports || "concept" %in% reports))) {
    # metadata
    writeLines("Generating metadata report")
    currentTable <- generateAOMetadataReport(conn, cdmDatabaseSchema, sourceOutputPath)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/metadata.csv"))

    # cdm source
    writeLines("Generating cdm source report")
    currentTable <- generateAOCdmSourceReport(conn, cdmDatabaseSchema, sourceOutputPath)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/cdmsource.csv"))

    # domain summary - observation period
    writeLines("Generating observation period reports")
    currentTable <- generateAOObservationPeriodReport(conn, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    filename <- file.path(sourceOutputPath, "observationperiod.json")
    write(jsonlite::toJSON(currentTable), filename)

    # death report
    writeLines("Generating death report")
    currentTable <- generateAODeathReport(conn, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    filename <- file.path(sourceOutputPath, "death.json")
    write(jsonlite::toJSON(currentTable), filename)

    writeLines("Generating domain summary reports")

    # domain summary - conditions
    dataConditions <- generateDomainSummaryConditions(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataConditions, file = paste0(sourceOutputPath, "/domain-summary-condition_occurrence.csv"))

    # domain summary - condition eras
    dataConditionEra <- generateDomainSummaryConditionEras(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataConditionEra, file = paste0(sourceOutputPath, "/domain-summary-condition_era.csv"))

    # domain summary - drugs
    dataDrugs <- generateDomainSummaryDrugs(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataDrugs, file = paste0(sourceOutputPath, "/domain-summary-drug_exposure.csv"))

    # domain stratification by drug type concept
    dataDrugType <- generateDomainDrugStratification(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataDrugType, file = paste0(sourceOutputPath, "/domain-drug-stratification.csv"))

    # domain summary - drug era
    dataDrugEra <- generateDomainSummaryDrugEra(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataDrugEra, file = paste0(sourceOutputPath, "/domain-summary-drug_era.csv"))

    # domain summary - measurements
    dataMeasurements <- generateDomainSummaryMeasurements(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataMeasurements, file = paste0(sourceOutputPath, "/domain-summary-measurement.csv"))

    # domain summary - observations
    dataObservations <- generateDomainSummaryObservations(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataObservations, file = paste0(sourceOutputPath, "/domain-summary-observation.csv"))

    # domain summary - visit details
    dataVisitDetails <- generateDomainSummaryVisitDetails(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataVisitDetails, file = paste0(sourceOutputPath, "/domain-summary-visit_detail.csv"))

    # domain summary - visits
    dataVisits <- generateDomainSummaryVisits(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataVisits, file = paste0(sourceOutputPath, "/domain-summary-visit_occurrence.csv"))

    # domain stratification by visit concept
    currentTable <- generateDomainVisitStratification(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/domain-visit-stratification.csv"))

    # domain summary - procedures
    dataProcedures <- generateDomainSummaryProcedures(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataProcedures, file = paste0(sourceOutputPath, "/domain-summary-procedure_occurrence.csv"))

    # domain summary - devices
    dataDevices <- generateDomainSummaryDevices(conn, resultsDatabaseSchema, vocabDatabaseSchema)
    data.table::fwrite(dataDevices, file = paste0(sourceOutputPath, "/domain-summary-device_exposure.csv"))
  }

  # domain summary - provider
  dataProviders <- generateDomainSummaryProvider(conn, resultsDatabaseSchema, vocabDatabaseSchema)
  data.table::fwrite(dataProviders, file = paste0(sourceOutputPath, "/domain-summary-provider.csv"))


  if (length(reports) == 0 || (length(reports) > 0 && "quality" %in% reports)) {
    writeLines("Generating quality completeness report")

    # quality - completeness
    currentTable <- generateQualityCompleteness(conn, resultsDatabaseSchema)
    data.table::fwrite(currentTable, file = paste0(sourceOutputPath, "/quality-completeness.csv"))

  }

  if (length(reports) == 0 || (length(reports) > 0 && "performance" %in% reports)) {
    writeLines("Generating achilles performance report")
    currentTable <- generateAOAchillesPerformanceReport(conn, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    data.table::fwrite(currentTable, file.path(sourceOutputPath, "achilles-performance.csv"))
  }

  if (length(reports) == 0 || (length(reports) > 0 && "concept" %in% reports)) {
    # concept level reporting

    columnsToNormalize <- c("CONCEPT_NAME", "NUM_PERSONS", "PERCENT_PERSONS", "RECORDS_PER_PERSON")

    writeLines("Generating visit reports")
    currentTable <- generateAOVisitReports(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "VISIT_DURATION_BY_TYPE", "AGE_AT_FIRST_OCCURRENCE")
    dir <- "/concepts/visit_occurrence"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "visit_occurrence", conceptsSchema)

    writeLines("Generating visit_detail reports")
    currentTable <- generateAOVisitDetailReports(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "VISIT_DETAIL_DURATION_BY_TYPE", "AGE_AT_FIRST_OCCURRENCE")
    dir <- "/concepts/visit_detail"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "visit_detail", conceptsSchema)

    writeLines("Generating Measurement reports")
    currentTable <- generateAOMeasurementReports(connectionDetails, dataMeasurements, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "FREQUENCY_DISTRIBUTION", "MEASUREMENTS_BY_TYPE", "AGE_AT_FIRST_OCCURRENCE", "RECORDS_BY_UNIT", "MEASUREMENT_VALUE_DISTRIBUTION", "LOWER_LIMIT_DISTRIBUTION", "UPPER_LIMIT_DISTRIBUTION", "VALUES_RELATIVE_TO_NORM")
    dir <- "/concepts/measurement"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "measurement", conceptsSchema)

    writeLines("Generating condition reports")
    currentTable <- generateAOConditionReports(connectionDetails, duckdbCon, dataConditions, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "CONDITIONS_BY_TYPE", "AGE_AT_FIRST_DIAGNOSIS")
    dir <- "/concepts/condition_occurrence"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "condition_occurrence", conceptsSchema)

    writeLines("Generating condition era reports")
    currentTable <- generateAOConditionEraReports(connectionDetails, dataConditionEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("AGE_AT_FIRST_EXPOSURE", "PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "LENGTH_OF_ERA")
    dir <- "/concepts/condition_era"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "condition_era", conceptsSchema)

    writeLines("Generating drug reports")
    currentTable <- generateAODrugReports(connectionDetails, dataDrugs, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("AGE_AT_FIRST_EXPOSURE", "DAYS_SUPPLY_DISTRIBUTION", "DRUGS_BY_TYPE", "PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "DRUG_FREQUENCY_DISTRIBUTION", "QUANTITY_DISTRIBUTION", "REFILLS_DISTRIBUTION")
    dir <- "/concepts/drug_exposure"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "drug_exposure", conceptsSchema)

    writeLines("Generating device exposure reports")
    currentTable <- generateAODeviceReports(connectionDetails, dataDevices, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("AGE_AT_FIRST_EXPOSURE", "DEVICES_BY_TYPE", "PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "DEVICE_FREQUENCY_DISTRIBUTION")
    dir <- "/concepts/device_exposure"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "device_exposure", conceptsSchema)

    writeLines("Generating drug era reports")
    currentTable <- generateAODrugEraReports(connectionDetails, dataDrugEra, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("AGE_AT_FIRST_EXPOSURE", "PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "LENGTH_OF_ERA")
    dir <- "/concepts/procedure_occurrence"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "drug_era", conceptsSchema)

    writeLines("Generating procedure reports")
    currentTable <- generateAOProcedureReports(connectionDetails, dataProcedures, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c('PREVALENCE_BY_GENDER_AGE_YEAR', 'PREVALENCE_BY_MONTH', 'PROCEDURE_FREQUENCY_DISTRIBUTION', 'PROCEDURES_BY_TYPE', 'AGE_AT_FIRST_OCCURRENCE')
    dir <- "/concepts/procedure_occurrence"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "procedure_occurrence", conceptsSchema)

    writeLines("Generating Observation reports")
    currentTable <- generateAOObservationReports(connectionDetails, dataObservations, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    columnsToConvertToDataFrame <- c("PREVALENCE_BY_GENDER_AGE_YEAR", "PREVALENCE_BY_MONTH", "OBS_FREQUENCY_DISTRIBUTION", "OBSERVATIONS_BY_TYPE", "AGE_AT_FIRST_OCCURRENCE")
    dir <- "/concepts/observation"
    lapply(currentTable$uniqueConcepts$CONCEPT_ID, function(concept_id, ...) {
      processAndExportConceptData(concept_id, ...)
    }, duckdbCon, currentTable$reports, sourceOutputPath, outputFormat, columnsToNormalize, columnsToConvertToDataFrame, dir, "observation", conceptsSchema)
  }

  if (length(reports) == 0 || (length(reports) > 0 && "person" %in% reports)) {
    writeLines("Generating person report")
    currentTable <- generateAOPersonReport(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema, vocabDatabaseSchema, sourceOutputPath)
    jsonOutput = jsonlite::toJSON(currentTable)
    write(jsonOutput, file = paste0(sourceOutputPath, "/person.json"))
  }
}


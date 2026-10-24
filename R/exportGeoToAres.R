# Geographic exposure export for ARES.
#
# Everything in this file is optional: a CDM without external_exposure / location data simply
# produces no geo output (see exportGeoToAres and the exportGeo argument of exportToAres).

geoSchemaVersion <- 1
geoRegionLevels <- c("county", "state")
geoDefaultPersonDomainConceptId <- 1147314

isSafeIdentifier <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x) && grepl("^[A-Za-z_][A-Za-z0-9_]*$", x)
}

# Returns list(ok, reason, hasHistory, countyColumn, stateColumn)
checkGeoSource <- function(connection, cdmDatabaseSchema, regionColumns) {
  skip <- function(reason) list(ok = FALSE, reason = reason)

  tables <- tolower(DatabaseConnector::getTableNames(connection, databaseSchema = cdmDatabaseSchema))
  if (!all(c("external_exposure", "location") %in% tables)) {
    return(skip("external_exposure and/or location table not found in the CDM schema"))
  }

  sql <- SqlRender::render(
    "SELECT COUNT_BIG(*) AS n FROM @cdm.external_exposure;",
    cdm = cdmDatabaseSchema
  )
  sql <- SqlRender::translate(sql, targetDialect = connection@dbms)
  if (DatabaseConnector::querySql(connection, sql)[1, 1] == 0) {
    return(skip("external_exposure is empty"))
  }

  fields <- tolower(DBI::dbListFields(connection, name = "location", databaseSchema = cdmDatabaseSchema))
  pick <- function(level) {
    col <- regionColumns[[level]]
    if (is.null(col) || is.na(col)) {
      return(NULL)
    }
    if (!isSafeIdentifier(col)) {
      stop("regionColumns must be plain column names, got: ", col)
    }
    if (tolower(col) %in% fields) tolower(col) else NULL
  }
  countyColumn <- pick("county")
  stateColumn <- pick("state")
  if (is.null(countyColumn) && is.null(stateColumn)) {
    return(skip(paste0(
      "location has neither a '", regionColumns[["county"]], "' nor a '", regionColumns[["state"]], "' column"
    )))
  }

  list(
    ok = TRUE,
    hasHistory = "location_history" %in% tables,
    countyColumn = countyColumn,
    stateColumn = stateColumn
  )
}

renderGeoSql <- function(connection, sqlFilename, ...) {
  SqlRender::loadRenderTranslateSql(
    sqlFilename = file.path("export", "geo", sqlFilename),
    packageName = "Achilles",
    dbms = connection@dbms,
    ...
  )
}

queryGeo <- function(connection, sqlFilename, ...) {
  df <- DatabaseConnector::querySql(connection, renderGeoSql(connection, sqlFilename, ...))
  names(df) <- tolower(names(df))
  df
}

# Pure aggregation step (no database access besides an in-process duckdb), kept separate so it can
# be tested directly. Inputs are data frames with the columns produced by the sqlGeo*.sql files.
#
# Statistics describe the distribution of person-level annual means. Cells whose distinct-person
# count is below minCellCount carry no statistics and are flagged SUPPRESSED.
buildGeoTables <- function(
  personYear,
  units,
  locations,
  residency,
  conceptNames,
  levels,
  minCellCount,
  regionIdScheme
) {
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  reg <- function(name, df) duckdb::duckdb_register(con, name, df)
  reg("person_year", personYear)
  reg("units", units)
  reg("locations", locations)
  reg("residency", residency)
  reg("concept_names", conceptNames)
  minCell <- as.character(as.integer(ceiling(minCellCount)))
  run <- function(sql) DBI::dbExecute(con, gsub("min_cell()", minCell, sql, fixed = TRUE))

  # person x region x concept x period at each requested level (state pools across counties)
  levelExpr <- list(county = "county_id", state = "state_id")
  exposureParts <- vapply(levels, function(level) {
    id <- levelExpr[[level]]
    sprintf(
      "SELECT '%s' AS region_level, %s AS region_id, exposure_concept_id, period, person_id,
              SUM(n_records) AS n_records,
              SUM(value_mean * n_records) / SUM(n_records) AS value_mean
       FROM person_year WHERE %s IS NOT NULL
       GROUP BY ALL",
      level, id, id
    )
  }, character(1))
  DBI::dbExecute(con, paste0("CREATE TABLE person_region AS ", paste(exposureParts, collapse = " UNION ALL ")))

  run("
    CREATE TABLE exposure_summary AS
    WITH agg AS (
      SELECT region_level, region_id, exposure_concept_id, period,
             COUNT(*) AS n_persons, SUM(n_records) AS n_records,
             AVG(value_mean) AS mean_value,
             quantile_cont(value_mean, 0.10) AS p10_value,
             quantile_cont(value_mean, 0.25) AS p25_value,
             quantile_cont(value_mean, 0.50) AS median_value,
             quantile_cont(value_mean, 0.75) AS p75_value,
             quantile_cont(value_mean, 0.90) AS p90_value
      FROM person_region GROUP BY ALL
    )
    SELECT region_level AS REGION_LEVEL, region_id AS REGION_ID,
           exposure_concept_id AS EXPOSURE_CONCEPT_ID, period AS PERIOD,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE n_persons END AS N_PERSONS,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE n_records END AS N_RECORDS,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE mean_value END AS MEAN_VALUE,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE p10_value END AS P10_VALUE,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE p25_value END AS P25_VALUE,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE median_value END AS MEDIAN_VALUE,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE p75_value END AS P75_VALUE,
           CASE WHEN n_persons < min_cell() THEN NULL ELSE p90_value END AS P90_VALUE,
           n_persons < min_cell() AS SUPPRESSED
    FROM agg")

  # residency: persons with a location_history entry overlapping each year
  periodRange <- DBI::dbGetQuery(con, "SELECT MIN(period) AS lo, MAX(period) AS hi FROM person_year")
  residencyParts <- vapply(levels, function(level) {
    id <- levelExpr[[level]]
    sprintf(
      "SELECT '%s' AS region_level, %s AS region_id, t.period AS period,
              COUNT(DISTINCT person_id) AS n_persons
       FROM residency, UNNEST(generate_series(
         GREATEST(CAST(start_year AS BIGINT), %d), LEAST(COALESCE(CAST(end_year AS BIGINT), %d), %d)
       )) AS t(period)
       WHERE %s IS NOT NULL GROUP BY ALL",
      level, id, as.integer(periodRange$lo), as.integer(periodRange$hi), as.integer(periodRange$hi), id
    )
  }, character(1))
  run(paste0(
    "CREATE TABLE residency_summary AS
     SELECT region_level AS REGION_LEVEL, region_id AS REGION_ID, period AS PERIOD,
            CASE WHEN n_persons < min_cell() THEN NULL ELSE n_persons END AS N_PERSONS_RESIDENT,
            n_persons < min_cell() AS SUPPRESSED
     FROM (", paste(residencyParts, collapse = " UNION ALL "), ")"
  ))

  # regions seen in either exposures or residency, with names and (suppressed when small) centroids
  locParts <- vapply(levels, function(level) {
    if (level == "county") {
      "SELECT 'county' AS region_level, county_id AS region_id, MAX(county_name) AS region_name,
              MAX(state_id) AS parent_region_id, SUM(latitude * n_locations) / SUM(n_locations) AS lat,
              SUM(longitude * n_locations) / SUM(n_locations) AS lon, SUM(n_locations) AS n_locations
       FROM locations WHERE county_id IS NOT NULL GROUP BY county_id"
    } else {
      "SELECT 'state' AS region_level, state_id AS region_id, state_id AS region_name,
              NULL AS parent_region_id, SUM(latitude * n_locations) / SUM(n_locations) AS lat,
              SUM(longitude * n_locations) / SUM(n_locations) AS lon, SUM(n_locations) AS n_locations
       FROM locations GROUP BY state_id"
    }
  }, character(1))
  DBI::dbExecute(con, paste0("CREATE TABLE loc AS ", paste(locParts, collapse = " UNION ALL ")))
  run("
    CREATE TABLE region AS
    WITH seen AS (
      SELECT DISTINCT REGION_LEVEL, REGION_ID FROM exposure_summary
      UNION SELECT DISTINCT REGION_LEVEL, REGION_ID FROM residency_summary
    )
    SELECT s.REGION_LEVEL, s.REGION_ID,
           COALESCE(l.region_name, s.REGION_ID) AS REGION_NAME,
           l.parent_region_id AS PARENT_REGION_ID,
           CASE WHEN l.n_locations >= min_cell() THEN ROUND(l.lat, 2) END AS CENTROID_LAT,
           CASE WHEN l.n_locations >= min_cell() THEN ROUND(l.lon, 2) END AS CENTROID_LON
    FROM seen s LEFT JOIN loc l ON l.region_level = s.REGION_LEVEL AND l.region_id = s.REGION_ID")

  DBI::dbExecute(con, "
    CREATE TABLE unit_pick AS
    SELECT exposure_concept_id, unit_concept_id FROM (
      SELECT exposure_concept_id, unit_concept_id,
             ROW_NUMBER() OVER (PARTITION BY exposure_concept_id ORDER BY n_records DESC) AS rn
      FROM units WHERE unit_concept_id IS NOT NULL AND unit_concept_id <> 0
    ) WHERE rn = 1")
  DBI::dbExecute(con, "
    CREATE TABLE exposure_concept AS
    SELECT e.EXPOSURE_CONCEPT_ID,
           COALESCE(cn.concept_name, 'Concept ' || e.EXPOSURE_CONCEPT_ID) AS EXPOSURE_NAME,
           'continuous' AS VALUE_KIND,
           COALESCE(u.unit_concept_id, 0) AS UNIT_CONCEPT_ID,
           COALESCE(un.concept_name, '') AS UNIT_NAME,
           MIN(e.P10_VALUE) AS GLOBAL_MIN, MAX(e.P90_VALUE) AS GLOBAL_MAX,
           MIN(e.PERIOD) AS PERIOD_MIN, MAX(e.PERIOD) AS PERIOD_MAX,
           COUNT(DISTINCT CASE WHEN NOT e.SUPPRESSED THEN e.REGION_ID END) AS N_REGIONS
    FROM exposure_summary e
    LEFT JOIN concept_names cn ON cn.concept_id = e.EXPOSURE_CONCEPT_ID
    LEFT JOIN unit_pick u ON u.exposure_concept_id = e.EXPOSURE_CONCEPT_ID
    LEFT JOIN concept_names un ON un.concept_id = u.unit_concept_id
    GROUP BY ALL")

  list(
    exposureSummary = DBI::dbGetQuery(con, "SELECT * FROM exposure_summary ORDER BY 1, 3, 4, 2"),
    exposureConcept = DBI::dbGetQuery(con, "SELECT * FROM exposure_concept ORDER BY 1"),
    region = DBI::dbGetQuery(con, "SELECT * FROM region ORDER BY 1, 2"),
    residency = DBI::dbGetQuery(con, "SELECT * FROM residency_summary ORDER BY 1, 3, 2"),
    periodMin = periodRange$lo,
    periodMax = periodRange$hi
  )
}

writeParquet <- function(df, path) {
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  duckdb::duckdb_register(con, "out_df", df)
  DBI::dbExecute(con, sprintf(
    "COPY out_df TO '%s' (FORMAT PARQUET)",
    gsub("'", "''", normalizePath(path, mustWork = FALSE))
  ))
}

# Core implementation shared by exportGeoToAres() and exportToAres().
# Returns the geo folder path, or NULL when there is nothing to export and required = FALSE.
generateGeoExport <- function(
  connection,
  cdmDatabaseSchema,
  vocabDatabaseSchema,
  releaseOutputPath,
  regionColumns,
  regionIdScheme,
  minCellCount,
  boundaryPath,
  personDomainConceptId,
  required
) {
  source <- checkGeoSource(connection, cdmDatabaseSchema, regionColumns)
  if (!source$ok) {
    if (required) {
      stop("Geographic export not possible: ", source$reason)
    }
    writeLines(paste0("Skipping geographic exposure export: ", source$reason))
    return(invisible(NULL))
  }
  if (!is.numeric(minCellCount) || length(minCellCount) != 1 || minCellCount < 1) {
    stop("minCellCount must be a single number >= 1")
  }

  # a level is produced only when its column exists; a missing one borrows the other column so
  # the SQL stays valid and is dropped from the output afterwards
  levels <- c(
    if (!is.null(source$countyColumn)) "county",
    if (!is.null(source$stateColumn)) "state"
  )
  countyColumn <- if (is.null(source$countyColumn)) source$stateColumn else source$countyColumn
  stateColumn <- if (is.null(source$stateColumn)) source$countyColumn else source$stateColumn

  writeLines(paste0("Generating geographic exposure report (levels: ", paste(levels, collapse = ", "), ")"))
  common <- list(
    cdm_database_schema = cdmDatabaseSchema,
    county_column = countyColumn,
    state_column = stateColumn
  )
  q <- function(file, ...) do.call(queryGeo, c(list(connection, file), common, list(...)))

  personYear <- q("sqlGeoExposurePersonYear.sql")
  if (nrow(personYear) == 0) {
    msg <- "no external_exposure rows with a numeric value and a resolvable location"
    if (required) stop("Geographic export not possible: ", msg)
    writeLines(paste0("Skipping geographic exposure export: ", msg))
    return(invisible(NULL))
  }
  if (is.null(source$countyColumn)) personYear$county_id <- NA_character_
  personYear$county_id <- as.character(personYear$county_id)
  personYear$state_id <- as.character(personYear$state_id)

  units <- queryGeo(
    connection, "sqlGeoExposureUnits.sql", cdm_database_schema = cdmDatabaseSchema
  )
  units$unit_concept_id <- as.numeric(units$unit_concept_id)
  units$n_records <- as.numeric(units$n_records)
  locations <- q("sqlGeoRegionLocations.sql")
  locations$county_id <- as.character(locations$county_id)
  locations$state_id <- as.character(locations$state_id)
  locations$n_locations <- as.numeric(locations$n_locations)

  residency <- if (source$hasHistory) {
    r <- q("sqlGeoResidency.sql", person_domain_concept_id = personDomainConceptId)
    r$county_id <- as.character(r$county_id)
    r$state_id <- as.character(r$state_id)
    r
  } else {
    writeLines("location_history not found; residency denominators will not be exported")
    data.frame(
      county_id = character(), state_id = character(), person_id = integer(),
      start_year = integer(), end_year = integer(), stringsAsFactors = FALSE
    )
  }

  conceptIds <- unique(c(personYear$exposure_concept_id, units$unit_concept_id))
  conceptIds <- conceptIds[!is.na(conceptIds) & conceptIds != 0]
  conceptNames <- tryCatch(
    queryGeo(
      connection, "sqlGeoConceptNames.sql",
      vocab_database_schema = vocabDatabaseSchema, concept_ids = conceptIds
    ),
    error = function(e) {
      writeLines("Concept names unavailable; exposures will be labelled by concept id")
      data.frame(concept_id = integer(), concept_name = character(), stringsAsFactors = FALSE)
    }
  )

  tables <- buildGeoTables(
    personYear = personYear,
    units = units,
    locations = locations,
    residency = residency,
    conceptNames = conceptNames,
    levels = levels,
    minCellCount = minCellCount,
    regionIdScheme = regionIdScheme
  )

  if (is.null(source$stateColumn)) {
    tables$region$PARENT_REGION_ID <- NA_character_
  }

  geoPath <- file.path(releaseOutputPath, "geo")
  unlink(geoPath, recursive = TRUE)
  dir.create(geoPath, showWarnings = FALSE, recursive = TRUE)
  files <- list(
    region = "geo_region.parquet",
    exposureConcept = "geo_exposure_concept.parquet",
    exposureSummary = "geo_exposure_summary.parquet",
    residency = "geo_residency.parquet"
  )
  writeParquet(tables$region, file.path(geoPath, files$region))
  writeParquet(tables$exposureConcept, file.path(geoPath, files$exposureConcept))
  writeParquet(tables$exposureSummary, file.path(geoPath, files$exposureSummary))
  if (nrow(tables$residency) > 0) {
    writeParquet(tables$residency, file.path(geoPath, files$residency))
  } else {
    files$residency <- NULL
  }

  boundaries <- stats::setNames(rep(list(NULL), length(levels)), levels)
  if (!is.null(boundaryPath)) {
    for (level in levels) {
      src <- file.path(boundaryPath, paste0("boundaries_", level, ".geojson"))
      if (file.exists(src)) {
        file.copy(src, file.path(geoPath, basename(src)), overwrite = TRUE)
        boundaries[[level]] <- basename(src)
      }
    }
  }

  manifest <- list(
    schemaVersion = geoSchemaVersion,
    generatedAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    levels = as.list(levels),
    regionIdScheme = regionIdScheme[levels],
    periodGranularity = "year",
    periodMin = tables$periodMin,
    periodMax = tables$periodMax,
    minCellCount = minCellCount,
    nExposures = nrow(tables$exposureConcept),
    hasResidency = !is.null(files$residency),
    boundaries = boundaries,
    files = files
  )
  write(jsonlite::toJSON(manifest, auto_unbox = TRUE, null = "null", pretty = TRUE),
        file.path(geoPath, "geo_manifest.json"))

  invisible(geoPath)
}

#' @title exportGeoToAres
#'
#' @description
#' \code{exportGeoToAres} Exports aggregated geographic exposure data for the ARES
#' "Geographic Exposures" report.
#'
#' @details
#' This export is entirely optional. It reads \code{external_exposure} (and \code{location},
#' optionally \code{location_history}) from the CDM, attributes each exposure to the region of the
#' location it was derived for, and writes aggregated parquet files plus a manifest to a
#' \code{geo} folder inside the ARES release folder (the same \code{<source>/<release>} folder
#' used by \code{exportToAres}). If the tables are missing or empty nothing is written and
#' \code{NULL} is returned.
#'
#' Statistics describe the distribution of person-level annual means (period = calendar year of
#' \code{exposure_start_date}). No person-level data and no exact coordinates are exported; cells
#' with fewer than \code{minCellCount} distinct persons are flagged as suppressed and carry no
#' statistics, and centroids are only exported for regions with at least that many locations.
#'
#' Region identifiers come from columns of the \code{location} table named in
#' \code{regionColumns}. The standard CDM has no FIPS column, so the county level needs a site
#' supplied column (default \code{county_fips}); without it only the state level is produced.
#'
#' @param connectionDetails   An R object of type ConnectionDetails.
#' @param cdmDatabaseSchema   Schema containing the OMOP CDM.
#' @param vocabDatabaseSchema Schema containing the vocabulary (for concept names). Default is cdmDatabaseSchema.
#' @param outputPath          Base ARES data folder, as passed to \code{exportToAres}.
#' @param regionColumns       Named character vector mapping region levels (\code{county}, \code{state})
#'                            to columns of the location table.
#' @param regionIdScheme      Named list describing how region ids should be matched to boundaries by ARES:
#'                            \code{us_fips} (county), \code{us_state_abbr} (state) or \code{custom}.
#' @param minCellCount        Minimum distinct persons for a cell to be reported. Default 11.
#' @param boundaryPath        Optional folder with \code{boundaries_county.geojson} and/or
#'                            \code{boundaries_state.geojson}, copied next to the export. When omitted
#'                            and the ids are US FIPS / state abbreviations, ARES uses its bundled
#'                            boundaries.
#' @param personDomainConceptId Concept id stored in location_history.domain_id for persons.
#'
#' @return The geo output folder (invisibly), or NULL if there was nothing to export.
#'
#' @export
exportGeoToAres <- function(
  connectionDetails,
  cdmDatabaseSchema,
  vocabDatabaseSchema = cdmDatabaseSchema,
  outputPath,
  regionColumns = c(county = "county_fips", state = "state"),
  regionIdScheme = list(county = "us_fips", state = "us_state_abbr"),
  minCellCount = 11,
  boundaryPath = NULL,
  personDomainConceptId = geoDefaultPersonDomainConceptId
) {
  conn <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection = conn))
  releasePath <- getAresReleasePath(conn, cdmDatabaseSchema, outputPath)
  generateGeoExport(
    connection = conn,
    cdmDatabaseSchema = cdmDatabaseSchema,
    vocabDatabaseSchema = vocabDatabaseSchema,
    releaseOutputPath = releasePath,
    regionColumns = regionColumns,
    regionIdScheme = regionIdScheme,
    minCellCount = minCellCount,
    boundaryPath = boundaryPath,
    personDomainConceptId = personDomainConceptId,
    required = FALSE
  )
}

# Same <source>/<release> folder convention as exportToAres
getAresReleasePath <- function(connection, cdmDatabaseSchema, outputPath) {
  sql <- SqlRender::render(
    sql = "select * from @cdmDatabaseSchema.cdm_source;",
    cdmDatabaseSchema = cdmDatabaseSchema
  )
  sql <- SqlRender::translate(sql = sql, targetDialect = connection@dbms)
  metadata <- DatabaseConnector::querySql(connection, sql)
  names(metadata) <- toupper(names(metadata)) # some platforms (e.g. duckdb) return lower case
  sourceKey <- gsub(" ", "_", metadata$CDM_SOURCE_ABBREVIATION)
  releaseDateKey <- format(lubridate::ymd(metadata$CDM_RELEASE_DATE), "%Y%m%d")
  file.path(outputPath, sourceKey, releaseDateKey)
}

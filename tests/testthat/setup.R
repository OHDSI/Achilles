if (Sys.getenv("CDM5_REDSHIFT_SERVER") != "") {
  library(DatabaseConnector)
  
  if (dir.exists(Sys.getenv("DATABASECONNECTOR_JAR_FOLDER"))) {
    jdbcDriverFolder <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
  } else {
    jdbcDriverFolder <- file.path(tempdir(), "jdbcDrivers")
    dir.create(jdbcDriverFolder, showWarnings = FALSE)
    DatabaseConnector::downloadJdbcDrivers("all", pathToDriver = jdbcDriverFolder)
    
    Sys.setenv(DATABASECONNECTOR_JAR_FOLDER = jdbcDriverFolder)
    
    withr::defer({
      unlink(jdbcDriverFolder,
             recursive = TRUE,
             force = TRUE)
    },
    testthat::teardown_env())
  }
} else {
  message("Skipping driver setup because environmental variables not set")
}
if (dir.exists(Sys.getenv("DATABASECONNECTOR_JAR_FOLDER"))) {
  jdbcDriverFolder <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
} else {
  jdbcDriverFolder <- "~/.jdbcDrivers"
  dir.create(jdbcDriverFolder, showWarnings = FALSE)
  DatabaseConnector::downloadJdbcDrivers("all", pathToDriver = jdbcDriverFolder)
  
  withr::defer(
    {
      unlink(jdbcDriverFolder, recursive = TRUE, force = TRUE)
    },
    testthat::teardown_env()
  )
}
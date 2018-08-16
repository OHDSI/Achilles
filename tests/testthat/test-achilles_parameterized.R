library(testthat)

# These tests currently just check if the main achilles function throws any errors on the different platforms and with single- and multi-threaded

dbTypes = c("mysql",
            "oracle",
            "postgresql",
            "redshift",
            "sql server",
            "pdw",
            "netezza",
            "bigquery")

for (dbType in dbTypes) {
  for (numThreads in c(1, 3)) {
    test_that(sprintf("Achilles main with %d threads does not throw an error on %s", numThreads, dbType), {
      sysUser <- Sys.getenv(sprintf("CDM5_%s_USER", toupper(dbType)))
      sysPassword <- URLdecode(Sys.getenv(sprintf("CDM5_%s_PASSWORD", toupper(dbType))))
      sysServer <- Sys.getenv(sprintf("CDM5_%s_SERVER", toupper(dbType)))
      sysExtraSettings <- Sys.getenv(sprintf("CDM5_%s_EXTRA_SETTINGS", toupper(dbType)))
      if (sysUser != "" &
          sysPassword != "" &
          sysServer != "") {
        cdmDatabaseSchema <- Sys.getenv(sprintf("CDM5_%s_CDM_SCHEMA", toupper(dbType)))
        resultsDatabaseSchema <- Sys.getenv("CDM5_%s_OHDSI_SCHEMA", toupper(dbType))
        
        details <- createConnectionDetails(dbms = dbType,
                                           user = sysUser,
                                           password = sysPassword,
                                           server = sysServer,
                                           extraSettings = sysExtraSettings)
        try(result <- Achilles::achilles(details, 
                               cdmDatabaseSchema = cdmDatabaseSchema, 
                               resultsDatabaseSchema = resultsDatabaseSchema, 
                               scratchDatabaseSchema = resultsDatabaseSchema,
                               sourceName = "NHANES", 
                               cdmVersion = "5", 
                               numThreads = numThreads, 
                               dropScratchTables = TRUE,
                               validateSchema = FALSE, 
                               createTable = TRUE, 
                               conceptHierarchy = FALSE,
                               createIndices = FALSE))
        if (file.exists("errorReport.txt")) {
          writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
        }
        expect_true(class(result) == "achillesResults")
      } else {
        writeLines(sprintf("Skipping %s main test", dbType))
      }
    })
  }
}

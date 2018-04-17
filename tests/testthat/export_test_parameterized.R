library(testthat)

# These tests currently just check if the export to JSON function throws any errors on the different platforms

dbTypes = c("mysql",
            "oracle",
            "postgresql",
            "redshift",
            "sql server",
            "pdw",
            "netezza",
            "bigquery")

for (dbType in dbTypes)
{
  test_that(sprintf("ExportToJson does not throw an error on %s", dbType), {
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
      try(exportToJson(details, 
                   cdmDatabaseSchema = cdmDatabaseSchema, 
                   resultsDatabaseSchema = resultsDatabaseSchema,
                   outputPath = dbType))
      if (file.exists("errorReport.txt")){
        writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
      }
      # dashboard.json is the last report to be generated:
      expect_true(file.exists(file.path(dbType, "dashboard.json")))
    } else {
      writeLines(spintf("Skipping %s export test", dbType))
    }
  })
}




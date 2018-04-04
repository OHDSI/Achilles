library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5

test_that("Achilles export does not throw an error on Oracle", {
  # Oracle
  if (Sys.getenv("CDM5_ORACLE_USER") != "") { 
    details <- createConnectionDetails(dbms = "oracle",
                                       user = Sys.getenv("CDM5_ORACLE_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_ORACLE_PASSWORD")),
                                       server = Sys.getenv("CDM5_ORACLE_SERVER"))
    try(exportToJson(details, 
                     cdmDatabaseSchema = Sys.getenv("CDM5_ORACLE_CDM_SCHEMA"), 
                     resultsDatabaseSchema = Sys.getenv("CDM5_ORACLE_OHDSI_SCHEMA"),
                     outputPath = "oracle",
                     cdmVersion = "5"))
    if (file.exists("errorReport.txt")){
      writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
    }
    # dashboard.json is the last report to be generated:
    expect_true(file.exists("oracle/dashboard.json"))
  } else {
    writeLines("Skipping oracle export test")
  }
})

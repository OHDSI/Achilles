library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5


test_that("Achilles export does not throw an error on SQL Server", {
  # SQL Server
  if (Sys.getenv("CDM5_SQL_SERVER_USER") != "") {   
    details <- createConnectionDetails(dbms = "sql server",
                                       user = Sys.getenv("CDM5_SQL_SERVER_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_SQL_SERVER_PASSWORD")),
                                       server = Sys.getenv("CDM5_SQL_SERVER_SERVER"))
    try(exportToJson(details, 
                     cdmDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_CDM_SCHEMA"), 
                     resultsDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_OHDSI_SCHEMA"),
                     outputPath = "sql_server",
                     cdmVersion = "5"))
    if (file.exists("errorReport.txt")){
      writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
    }
    # dashboard.json is the last report to be generated:
    expect_true(file.exists("sql_server/dashboard.json"))
  } else {
    writeLines("Skipping sql server export test")
  }
})

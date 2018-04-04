library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5

test_that("Achilles export does not throw an error on Postgres", {
  # Postgresql
  if (Sys.getenv("CDM5_POSTGRESQL_USER") != "") {   
    details <- createConnectionDetails(dbms = "postgresql",
                                       user = Sys.getenv("CDM5_POSTGRESQL_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_POSTGRESQL_PASSWORD")),
                                       server = Sys.getenv("CDM5_POSTGRESQL_SERVER"))
    try(exportToJson(details, 
                     cdmDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"), 
                     resultsDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_OHDSI_SCHEMA"),
                     outputPath = "postgresql",
                     cdmVersion = "5"))
    if (file.exists("errorReport.txt")){
      writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
    }
    # dashboard.json is the last report to be generated:
    expect_true(file.exists("postgresql/dashboard.json"))
  } else {
    writeLines("Skipping postgress export test")
  }
})

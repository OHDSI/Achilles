library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5

test_that("Achilles main does not throw an error on Postgres", {
  # Postgresql
  if (Sys.getenv("CDM5_POSTGRESQL_USER") != "") {
    details <- createConnectionDetails(dbms = "postgresql",
                                       user = Sys.getenv("CDM5_POSTGRESQL_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_POSTGRESQL_PASSWORD")),
                                       server = Sys.getenv("CDM5_POSTGRESQL_SERVER"))
    try(result <- achilles(details, 
                           cdmDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"), 
                           resultsDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_OHDSI_SCHEMA"), 
                           sourceName = "NHANES", 
                           cdmVersion = "5", 
                           validateSchema = FALSE, 
                           createTable = TRUE,
                           conceptHierarchy = FALSE,
                           createIndices = FALSE))
    if (file.exists("errorReport.txt")){
      writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
    }
    expect_true(class(result) == "achillesResults")
  } else {
    writeLines("Skipping postgress main test")
  }
})


library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5

test_that("Achilles main does not throw an error on BigQuery", {
  # BigQuery
  if (Sys.getenv("CDM5_BIGQUERY_USER") != "") {
    details <- createConnectionDetails(dbms = "bigquery",
                                       user = Sys.getenv("CDM5_BIGQUERY_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_BIGQUERY_PASSWORD")),
                                       server = Sys.getenv("CDM5_BIGQUERY_SERVER"),
                                       extraSettings = Sys.getenv("CDM5_BIGQUERY_EXTRA_SETTINGS"))
    try(result <- achilles(details, 
                           cdmDatabaseSchema = Sys.getenv("CDM5_BIGQUERY_CDM_SCHEMA"), 
                           resultsDatabaseSchema = Sys.getenv("CDM5_BIGQUERY_OHDSI_SCHEMA"), 
                           sourceName = "OHDSI CDM V5 Database", 
                           cdmVersion = "5", 
                           validateSchema = FALSE, 
                           createTable = TRUE,
                           conceptHierarchy = FALSE))
    if (file.exists("errorReport.txt")){
      writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
    }
    expect_true(class(result) == "achillesResults")
  } else {
    writeLines("Skipping bigquery main test")
  }
})


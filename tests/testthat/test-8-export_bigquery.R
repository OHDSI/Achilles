library(testthat)

# These tests currently just check if the main achilles function and export functions don't throw any errors on the different platforms
# Note: Currently only checking CDM v5

test_that("Achilles export does not throw an error on BigQuery", {
  # BigQuery
  if (Sys.getenv("CDM5_BIGQUERY_USER") != "") { 
    details <- createConnectionDetails(dbms = "bigquery",
                                       user = Sys.getenv("CDM5_BIGQUERY_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_BIGQUERY_PASSWORD")),
                                       server = Sys.getenv("CDM5_BIGQUERY_SERVER"),
                                       extraSettings = Sys.getenv("CDM5_BIGQUERY_EXTRA_SETTINGS"))
    try(exportToJson(details, 
                     cdmDatabaseSchema = Sys.getenv("CDM5_BIGQUERY_CDM_SCHEMA"), 
                     resultsDatabaseSchema = Sys.getenv("CDM5_BIGQUERY_OHDSI_SCHEMA"),
                     outputPath = "bigquery",
                     cdmVersion = "5"))
    if (file.exists("errorReport.txt")){
      writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
    }
    # dashboard.json is the last report to be generated:
    expect_true(file.exists("bigquery/dashboard.json"))
  } else {
    writeLines("Skipping bigquery export test")
  }
})

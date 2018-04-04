library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5

test_that("Achilles main does not throw an error on Oracle", {
  # Oracle
  if (Sys.getenv("CDM5_ORACLE_USER") != "") {  
    details <- createConnectionDetails(dbms = "oracle",
                                       user = Sys.getenv("CDM5_ORACLE_USER"),
                                       password = URLdecode(Sys.getenv("CDM5_ORACLE_PASSWORD")),
                                       server = Sys.getenv("CDM5_ORACLE_SERVER"))
    try(result <- achilles(details, 
                           cdmDatabaseSchema = Sys.getenv("CDM5_ORACLE_CDM_SCHEMA"), 
                           resultsDatabaseSchema = Sys.getenv("CDM5_ORACLE_OHDSI_SCHEMA"), 
                           oracleTempSchema = Sys.getenv("CDM5_ORACLE_OHDSI_SCHEMA"), 
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
    writeLines("Skipping oracle main test")
  }
})

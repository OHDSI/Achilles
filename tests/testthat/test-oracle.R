test_that("Achilles Oracle Execution", {
  if (Sys.getenv("CDM5_ORACLE_SERVER") != "") {
    details <- createConnectionDetails(
      dbms = "oracle",
      user = Sys.getenv("CDM5_ORACLE_USER"),
      password = URLdecode(Sys.getenv("CDM5_ORACLE_PASSWORD")),
      server = Sys.getenv("CDM5_ORACLE_SERVER")
    )
    
    expect_no_error(
      Achilles::achilles(
        connectionDetails = details,
        cdmDatabaseSchema = Sys.getenv("CDM5_ORACLE_CDM54_SCHEMA"),
        resultsDatabaseSchema = Sys.getenv("CDM5_ORACLE_OHDSI_SCHEMA"),
        cdmVersion = "5.4",
        createTable = T
      )
    )
  } else {
    message("Skipping Oracle testing because environmental variables not set")
  }
})

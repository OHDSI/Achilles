test_that("Achilles Redshift Execution", {
  if (Sys.getenv("CDM5_REDSHIFT_SERVER") != "") {
    details <- createConnectionDetails(
      dbms = "redshift",
      user = Sys.getenv("CDM5_REDSHIFT_USER"),
      password = URLdecode(Sys.getenv("CDM5_REDSHIFT_PASSWORD")),
      server = Sys.getenv("CDM5_REDSHIFT_SERVER")
    )
    
    expect_no_error(
      Achilles::achilles(
        connectionDetails = details,
        cdmDatabaseSchema = Sys.getenv("CDM5_REDSHIFT_CDM54_SCHEMA"),
        resultsDatabaseSchema = Sys.getenv("CDM5_REDSHIFT_OHDSI_SCHEMA"),
        cdmVersion = "5.4",
        createTable = T
      )
    )
  } else {
    message("Skipping Redshift testing because environmental variables not set")
  }
})

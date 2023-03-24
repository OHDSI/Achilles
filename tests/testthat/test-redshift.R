test_that("Achilles Redshift Execution", {
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
      createTable = T
    )  
  )
})  

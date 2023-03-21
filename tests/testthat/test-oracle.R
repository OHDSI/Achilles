test_that("Achilles Oracle Execution", {
  details <- createConnectionDetails(
    dbms = "oracle",
    user = Sys.getenv("CDM5_ORACLE_USER"),
    password = URLdecode(Sys.getenv("CDM5_ORACLE_PASSWORD")),
    server = Sys.getenv("CDM5_ORACLE_SERVER")
  )

  expect_no_error(
    Achilles::achilles(
      connectionDetails = details, 
      cdmDatabaseSchema = Sys.getenv("CDM5_ORACLE_CDM_SCHEMA"),
      createTable = T
    )
  )
})  

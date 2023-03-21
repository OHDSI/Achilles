test_that("Achilles MS SQL Execution", {
  details <- createConnectionDetails(
    dbms = "sql server",
    user = Sys.getenv("CDM5_SQL_SERVER_USER"),    
    password = URLdecode(Sys.getenv("CDM5_SQL_SERVER_PASSWORD")),
    server = Sys.getenv("CDM5_SQL_SERVER_SERVER")
  )
  
  expect_no_error(
    Achilles::achilles(
      connectionDetails = details, 
      cdmDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_CDM_SCHEMA"),
      createTable = T
    )  
  )
})  

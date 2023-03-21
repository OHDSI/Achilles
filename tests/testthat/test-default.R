test_that("Achilles Execution", {
  
  # Postgresql --------------------------------------------------

  details <- createConnectionDetails(
    dbms = "postgresql",
    user = Sys.getenv("CDM5_POSTGRESQL_USER"),
    password = URLdecode(Sys.getenv("CDM5_POSTGRESQL_PASSWORD")),
    server = Sys.getenv("CDM5_POSTGRESQL_SERVER")
  )
  
  expect_no_error(
    Achilles::achilles(
    connectionDetails = details, 
    cdmDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"),
    createTable = T
    )
  )

  # SQL Server --------------------------------------------------
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
  
  # Oracle --------------------------------------------------
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
  
  # RedShift  --------------------------------------------------
  details <- createConnectionDetails(
    dbms = "redshift",
    user = Sys.getenv("CDM5_REDSHIFT_USER"),
    password = URLdecode(Sys.getenv("CDM5_REDSHIFT_PASSWORD")),
    server = Sys.getenv("CDM5_REDSHIFT_SERVER")
  )
  
  expect_no_error(
    Achilles::achilles(
      connectionDetails = details, 
      cdmDatabaseSchema = Sys.getenv("CDM5_REDSHIFT_CDM_SCHEMA"),
      createTable = T
    )  
  )
  
})  

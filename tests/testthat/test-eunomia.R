test_that("achilles works test", {
  test_that("Open and close connection", {
    # Postgresql --------------------------------------------------
    details <- createConnectionDetails(
      dbms = "postgresql",
      user = Sys.getenv("CDM5_POSTGRESQL_USER"),
      password = URLdecode(Sys.getenv("CDM5_POSTGRESQL_PASSWORD")),
      server = Sys.getenv("CDM5_POSTGRESQL_SERVER")
    )
    connection <- connect(details)
    expect_true(inherits(connection, "DatabaseConnectorConnection"))
    expect_equal(dbms(connection), "postgresql")
    expect_true(disconnect(connection))
    
    # SQL Server --------------------------------------------------
    details <- createConnectionDetails(
      dbms = "sql server",
      user = Sys.getenv("CDM5_SQL_SERVER_USER"),    
      password = URLdecode(Sys.getenv("CDM5_SQL_SERVER_PASSWORD")),
      server = Sys.getenv("CDM5_SQL_SERVER_SERVER")
    )
    connection <- connect(details)
    expect_true(inherits(connection, "DatabaseConnectorConnection"))
    expect_equal(dbms(connection), "sql server")
    expect_true(disconnect(connection))
    
    # Oracle --------------------------------------------------
    details <- createConnectionDetails(
      dbms = "oracle",
      user = Sys.getenv("CDM5_ORACLE_USER"),
      password = URLdecode(Sys.getenv("CDM5_ORACLE_PASSWORD")),
      server = Sys.getenv("CDM5_ORACLE_SERVER")
    )
    connection <- connect(details)
    expect_true(inherits(connection, "DatabaseConnectorConnection"))
    expect_equal(dbms(connection), "oracle")
    expect_true(disconnect(connection))
    
    # RedShift  --------------------------------------------------
    details <- createConnectionDetails(
      dbms = "redshift",
      user = Sys.getenv("CDM5_REDSHIFT_USER"),
      password = URLdecode(Sys.getenv("CDM5_REDSHIFT_PASSWORD")),
      server = Sys.getenv("CDM5_REDSHIFT_SERVER")
    )
    connection <- connect(details)
    expect_true(inherits(connection, "DatabaseConnectorConnection"))
    expect_equal(dbms(connection), "redshift")
    expect_true(disconnect(connection))
  })  
})
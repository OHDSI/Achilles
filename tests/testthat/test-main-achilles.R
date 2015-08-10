library(testthat)

# These tests currently just check if the main achilles function and export functiosn don't throw any errors on the different platforms
# Note: Currently only checking CDM v5


test_that("Achilles main does not throw an error on Postgres", {
  # Postgresql
  details <- createConnectionDetails(dbms = "postgresql",
                                     user = Sys.getenv("CDM5_POSTGRESQL_USER"),
                                     password = URLdecode(Sys.getenv("CDM5_POSTGRESQL_PASSWORD")),
                                     server = Sys.getenv("CDM5_POSTGRESQL_SERVER"))
  try(result <- achilles(details, 
                         cdmDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"), 
                         resultsDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_OHDSI_SCHEMA"), 
                         sourceName = "NHANES", 
                         cdmVersion = "5", 
                         validateSchema = FALSE, 
                         createTable = TRUE))
  if (file.exists("errorReport.txt")){
    writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
  }
  expect_true(class(result) == "achillesResults")
})

test_that("Achilles main does not throw an error on SQL Server", {
  # SQL Server
  details <- createConnectionDetails(dbms = "sql server",
                                     user = Sys.getenv("CDM5_SQL_SERVER_USER"),
                                     password = URLdecode(Sys.getenv("CDM5_SQL_SERVER_PASSWORD")),
                                     server = Sys.getenv("CDM5_SQL_SERVER_SERVER"))
  try(result <- achilles(details, 
                         cdmDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_CDM_SCHEMA"), 
                         resultsDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_OHDSI_SCHEMA"), 
                         sourceName = "NHANES", 
                         cdmVersion = "5", 
                         validateSchema = FALSE, 
                         createTable = TRUE))
  if (file.exists("errorReport.txt")){
    writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
  }
  expect_true(class(result) == "achillesResults")
})

test_that("Achilles main does not throw an error on Oracle", {
  # Oracle
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
                         createTable = TRUE))
  if (file.exists("errorReport.txt")){
    writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
  }
  expect_true(class(result) == "achillesResults")
})

test_that("Achilles export does not throw an error on Postgres", {
  # Postgresql
  details <- createConnectionDetails(dbms = "postgresql",
                                     user = Sys.getenv("CDM5_POSTGRESQL_USER"),
                                     password = URLdecode(Sys.getenv("CDM5_POSTGRESQL_PASSWORD")),
                                     server = Sys.getenv("CDM5_POSTGRESQL_SERVER"))
  try(exportToJson(details, 
                   cdmDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_CDM_SCHEMA"), 
                   resultsDatabaseSchema = Sys.getenv("CDM5_POSTGRESQL_OHDSI_SCHEMA"),
                   outputPath = "postgresql",
                   cdmVersion = "5"))
  if (file.exists("errorReport.txt")){
    writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
  }
  # dashboard.json is the last report to be generated:
  expect_true(file.exists("postgresql/dashboard.json"))
})

test_that("Achilles export does not throw an error on SQL Server", {
  # SQL Server
  details <- createConnectionDetails(dbms = "sql server",
                                     user = Sys.getenv("CDM5_SQL_SERVER_USER"),
                                     password = URLdecode(Sys.getenv("CDM5_SQL_SERVER_PASSWORD")),
                                     server = Sys.getenv("CDM5_SQL_SERVER_SERVER"))
  try(exportToJson(details, 
                   cdmDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_CDM_SCHEMA"), 
                   resultsDatabaseSchema = Sys.getenv("CDM5_SQL_SERVER_OHDSI_SCHEMA"),
                   outputPath = "sql_server",
                   cdmVersion = "5"))
  if (file.exists("errorReport.txt")){
    writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
  }
  # dashboard.json is the last report to be generated:
  expect_true(file.exists("sql_server/dashboard.json"))
})

test_that("Achilles export does not throw an error on Oracle", {
  # Oracle
  details <- createConnectionDetails(dbms = "oracle",
                                     user = Sys.getenv("CDM5_ORACLE_USER"),
                                     password = URLdecode(Sys.getenv("CDM5_ORACLE_PASSWORD")),
                                     server = Sys.getenv("CDM5_ORACLE_SERVER"))
  try(exportToJson(details, 
                   cdmDatabaseSchema = Sys.getenv("CDM5_ORACLE_CDM_SCHEMA"), 
                   resultsDatabaseSchema = Sys.getenv("CDM5_ORACLE_OHDSI_SCHEMA"),
                   outputPath = "oracle",
                   cdmVersion = "5"))
  if (file.exists("errorReport.txt")){
    writeLines(readChar("errorReport.txt", file.info("errorReport.txt")$size))
  }
  # dashboard.json is the last report to be generated:
  expect_true(file.exists("oracle/dashboard.json"))
})


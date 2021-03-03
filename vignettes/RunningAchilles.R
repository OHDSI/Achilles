## ---- echo = FALSE, message = FALSE, warning = FALSE--------------------------
library(Achilles)
knitr::opts_chunk$set(
  cache = FALSE,
  comment = "#>",
  error = FALSE,
  tidy = FALSE)

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  
#  achilles(connectionDetails = connectionDetails,
#           cdmDatabaseSchema = "cdm",
#           resultsDatabaseSchema = "results",
#           vocabDatabaseSchema = "vocab",
#           sourceName = "Synpuf",
#           cdmVersion = 5.3,
#           numThreads = 1,
#           runHeel = FALSE)

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  
#  achilles(connectionDetails = connectionDetails,
#           cdmDatabaseSchema = "cdm",
#           resultsDatabaseSchema = "results",
#           scratchDatabaseSchema = "scratch",
#           vocabDatabaseSchema = "vocab",
#           sourceName = "Synpuf",
#           cdmVersion = 5.3,
#           numThreads = 5,
#           runHeel = FALSE)

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  
#  achillesHeel(connectionDetails = connectionDetails,
#               cdmDatabaseSchema = "cdm",
#               resultsDatabaseSchema = "results",
#               vocabDatabaseSchema = "vocab",
#               cdmVersion = 5.3,
#               numThreads = 1,
#               outputFolder = "output")

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  achillesHeel(connectionDetails = connectionDetails,
#               cdmDatabaseSchema = "cdm",
#               resultsDatabaseSchema = "results",
#               vocabDatabaseSchema = "vocab",
#               cdmVersion = 5.3,
#               numThreads = 5,
#               outputFolder = "output",
#               scratchDatabaseSchema = "scratch")
#  

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  
#  createIndices(connectionDetails = connectionDetails,
#                resultsDatabaseSchema = "results",
#                outputFolder = "output")

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  
#  dropAllScratchTables(connectionDetails = connectionDetails,
#                       scratchDatabaseSchema = "scratch", numThreads = 5)

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  connectionDetails <- createConnectionDetails(dbms = "postgresql",
#                                               server = "localhost/synpuf",
#                                               user = "cdm_user",
#                                               password = "cdm_password")
#  
#  exportToJson(connectionDetails = connectionDetails,
#               cdmDatabaseSchema = "cdm",
#               resultsDatabaseSchema = "results",
#               outputPath = "output",
#               vocabDatabaseSchema = "vocab")

## ----tidy = FALSE, eval = FALSE-----------------------------------------------
#  addDataSource(jsonFolderPath = "output",
#                dataSourcePath = "achillesWeb")

## ----tidy = TRUE, eval = TRUE-------------------------------------------------
citation("Achilles")


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
#  		 outputFolder = "output")

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
#  		 numThreads = 5,
#           outputFolder = "output")

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

## ----tidy = TRUE, eval = TRUE-------------------------------------------------
citation("Achilles")


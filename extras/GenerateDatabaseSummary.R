library(dplyr)
library(knitr)
library(kableExtra)

options(connectionObserver = NULL)

demoCountry <- "United States"
demoProvenance <- "Synthetic"
connectionDetails <- Eunomia::getEunomiaConnectionDetails()

cdmDatabaseSchema <- "main"
resultsDatabaseSchema <- "main"

cdmVersion <- "5.3"

Achilles::achilles(
  cdmVersion = cdmVersion,
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = cdmDatabaseSchema,
  smallCellCount = 0,
  createTable = TRUE,
  createIndices = FALSE,
  sqlOnly = FALSE
)

dbSummary <- Achilles::generateDbSummary(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema,demoCountry,demoProvenance)

tableOutput <- dbSummary$summary
tableOutput$"Source Vocabularies" <- paste(dbSummary$sourceVocabs$VOCABULARY_ID, collapse="<br>")
tableOutput$"Visits" <- paste(dbSummary$visitDist$CONCEPT_NAME, collapse="<br>")


# this will open results in the RStudio Viewer which can then be exported to image or html.
kbl(tableOutput,escape=F) %>% kableExtra::kable_styling()


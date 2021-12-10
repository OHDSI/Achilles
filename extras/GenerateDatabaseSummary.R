library(dplyr)
library(knitr)
library(kableExtra)

options(connectionObserver = NULL)

demoCountry <- "United States"
demoProvenance <- "Synthetic"

dbSummary <- generateDbSummary(connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema,demoCountry,demoProvenance)

tableOutput <- dbSummary$summary
tableOutput$"Source Vocabularies" <- paste(dbSummary$sourceVocabs$VOCABULARY_ID, collapse="<br>")
tableOutput$"Visits" <- paste(dbSummary$visitDist$CONCEPT_NAME, collapse="<br>")

# this will open results in the RStudio Viewer which can then be exported to image or html.
kable(tableOutput,escape=F) %>% kableExtra::kable_styling()

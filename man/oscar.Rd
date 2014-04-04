\name{oscar}
\alias{oscar}
\title{oscar}
\usage{
oscar(connectionDetails, cdmSchema, resultsSchema, sourceName)
}
\arguments{
  \item{connectionDetails}{An R object of type
  ConnectionDetail (details for the function that contains
  server info, database type, optionally username/password,
  port)}

  \item{cdmSchema}{string name of databsae schema that
  contains OMOP CDM and vocabulary}

  \item{resultsSchema}{string name of database schema that
  we can write results to}

  \item{sourceName}{string name of the database, as
  recorded in results}
}
\value{
A connectionDetails list pointing to the database
containing the results
}
\description{
\code{oscar} creates descriptive statistics summary for an
entire OMOP CDM instance.
}
\details{
PATRICK HOMEWORK: complete details This function loads the
appropriate database driver, which is included in the
library, and connects to the database server.
}
\examples{
\dontrun{
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  resultsConnectionDetails <- oscar(connectionDetails, "cdm4_sim", "scratch", "TestDB")
  plotPopulation(resultConnectionDetails)
}
}


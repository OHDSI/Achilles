\name{achilles}
\alias{achilles}
\title{achilles}
\usage{
achilles(connectionDetails, cdmSchema, resultsSchema, sourceName = "",
  analysisIds)
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

  \item{analysisIds}{(optional) a vector containing the set
  of Achilles analysisIds for which results will be
  generated. If not specified, all analyses will be
  executed.}
}
\value{
An object of type \code{oscarResults} containing details
for connecting to the database containing the results
}
\description{
\code{achilles} creates descriptive statistics summary for
an entire OMOP CDM instance.
}
\details{
PATRICK HOMEWORK: complete details
}
\examples{
\dontrun{
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
  plot(achillesResults, "population")
}
}


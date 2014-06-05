\name{achillesHeel}
\alias{achillesHeel}
\title{achillesHeel}
\usage{
achillesHeel(connectionDetails, resultsSchema)
}
\arguments{
  \item{connectionDetails}{An R object of type
  ConnectionDetail (details for the function that contains
  server info, database type, optionally username/password,
  port)}

  \item{resultsSchema}{string name of database schema
  containing the Achilles descriptive statistics. Default
  is cdmSchema}
}
\value{
An object of type \code{achillesHeelResults} containing the
list of any data quality issues.
}
\description{
\code{achillesHeel} uses the Achilles descriptive
statistics to identify potential data quality issues.
}
\details{
PATRICK HOMEWORK: complete details
}
\examples{
\dontrun{
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  achillesResults <- achilles(connectionDetails, "cdm4_sim", "scratch", "TestDB")
  achillesHeelResults <- achillesHeel(connectionDetails, "scratch")
  summary(achillesHeelResults)
}
}


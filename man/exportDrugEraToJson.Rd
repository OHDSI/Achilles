\name{exportDrugEraToJson}
\alias{exportDrugEraToJson}
\title{exportDrugEraToJson}
\usage{
exportDrugEraToJson(connectionDetails, cdmSchema, resultsSchema,
  outputPath = getwd())
}
\arguments{
  \item{connectionDetails}{An R object of type
  ConnectionDetail (details for the function that contains
  server info, database type, optionally username/password,
  port)}

  \item{cdmSchema}{Name of the database schema that
  contains the vocabulary files}

  \item{resultsSchema}{Name of the database schema that
  contains the Achilles analysis files. Default is
  cdmSchema}

  \item{outputPath}{A folder location to save the JSON
  files. Default is current working folder}
}
\value{
none
}
\description{
\code{exportDrugEraToJson} Exports Achilles Drug Era report
into a JSON form for reports.
}
\details{
Creates individual files for Drug Era report found in
Achilles.Web
}
\examples{
\dontrun{
  connectionDetails <- createConnectionDetails(dbms="sql server", server="yourserver")
  exportDrugEraToJson(connectionDetails, cdmSchema="cdm4_sim", outputPath="your/output/path")
}
}


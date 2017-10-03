#Requires that Achilles has been run first

testAchillesViestResultsCode <- function(){
  #Test on SQL Server: 
  setwd("c:/temp")
  connectionDetailsSqlServer <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
  fetchAchillesHeelResults(connectionDetailsSqlServer, resultsDatabase="my_cdm")
  fetchAchillesAnalysisResults(connectionDetailsSqlServer, resultsDatabase = "my_cdm", analysisId = 106)
  
  
  pw <- ""
  
  ### Test Achilles heel part ###
  
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
  fetchAchillesHeelResults(connectionDetails,  resultsDatabase = "scratch")

  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  fetchAchillesHeelResults(connectionDetails, resultsDatabase = "scratch")

  

  #Test on Oracle 
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="oracle", server="xe", user="system",password="OHDSI2")
  fetchAchillesHeelResults(connectionDetails, resultsDatabase = "scratch")

  
  ### Test Achilles analysis results view part ###
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server="myserver")
  fetchAchillesAnalysisResults(connectionDetails,  resultsDatabase = "scratch", analysisId = 106)
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  fetchAchillesAnalysisResults(connectionDetails, resultsDatabase = "scratch", analysisId = 106)
  
  

  #Test on Oracle
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="oracle", server="xe", user="system",password="OHDSI2")
  fetchAchillesAnalysisResults(connectionDetails, resultsDatabase = "scratch", analysisId = 106)
  
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  for (analysisId in analysesDetails$ANALYSIS_ID){
    results <- fetchAchillesAnalysisResults(connectionDetails, resultsDatabase = "scratch", analysisId = analysisId)
  }
}
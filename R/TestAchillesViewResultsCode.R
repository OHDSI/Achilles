#Requires that Achilles has been run first

testAchillesViestResultsCode <- function(){
  #Test on SQL Server: 
  setwd("c:/temp")
  connectionDetailsSqlServer <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT09.jnj.com")
  fetchAchillesHeelResults(connectionDetailsSqlServer, resultsSchema="CDM_TRUVEN_CCAE_6k")
  fetchAchillesAnalysisResults(connectionDetailsSqlServer, resultsSchema = "CDM_TRUVEN_CCAE_6k", analysisId = 106)
  
  
  pw <- ""
  
  ### Test Achilles heel part ###
  
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  fetchAchillesHeelResults(connectionDetails,  resultsSchema = "scratch")

  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  fetchAchillesHeelResults(connectionDetails, resultsSchema = "scratch")

  
  #Test on PostgreSQL sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  fetchAchillesHeelResults(connectionDetails, resultsSchema = "scratch_sample")
  
  #Test on Oracle sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  fetchAchillesHeelResults(connectionDetails, resultsSchema = "scratch")

  
  ### Test Achilles analysis results view part ###
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  fetchAchillesAnalysisResults(connectionDetails,  resultsSchema = "scratch", analysisId = 106)
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  fetchAchillesAnalysisResults(connectionDetails, resultsSchema = "scratch", analysisId = 106)
  
  
  #Test on PostgreSQL sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  fetchAchillesAnalysisResults(connectionDetails, resultsSchema = "scratch_sample", analysisId = 106)
  
  #Test on Oracle sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  fetchAchillesAnalysisResults(connectionDetails, resultsSchema = "scratch", analysisId = 106)
  
  
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  for (analysisId in analysesDetails$ANALYSIS_ID){
    results <- fetchAchillesAnalysisResults(connectionDetails, resultsSchema = "scratch", analysisId = analysisId)
  }
}
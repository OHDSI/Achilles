#Requires that Achilles has been run first

testAchillesHeelCode <- function(){
  pw <- "F1r3starter"
  
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  ahr <- achillesHeel(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch")
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  ahr <- achillesHeel(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch")
  
  #Test on PostgreSQL sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  ahr <- achillesHeel(connectionDetails, cdmSchema = "cdm4_sim_sample", resultsSchema = "scratch_sample")
  
  #Test on Oracle sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  ahr <- achillesHeel(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch")
  
}
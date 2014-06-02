# some more test-code

testExportCode <- function(){
  
  pw <- "F1r3starter"
  
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/SqlServer")
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim_sample", resultsSchema = "scratch_sample",outputPath = "c:/temp/PosgreSQL")
  
  #Test on Oracle
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/Oracle")
  
}
#cdmSchema <- "cdm4_sim"
#connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw, schema="scratch_sample")
#conn <- connect(connectionDetails)

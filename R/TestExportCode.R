# some more test-code

testExportCode <- function(){
  pw <- ""
  #sqlServerServer <- "myserver"
  #sqlServerresultsDatabaseSchema <- "scratch"
  #schema <- "cdm4_sim"
  
  sqlServerServer <- "myserver"
  
  sqlServerresultsDatabaseSchema <- "cdm_truven_ccae_6k.dbo"
  schema <- "cdm_truven_ccae_6k.dbo"
  cdmVersion <- "4"
  
  sqlServerresultsDatabaseSchema <- "cdm_truven_ccae_6k_v5.dbo"
  schema <- "cdm_truven_ccae_6k_v5.dbo"
  cdmVersion <- "5"
  
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server", server=sqlServerServer)
  exportToJson(connectionDetails, cdmDatabaseSchema = schema, resultsDatabaseSchema = sqlServerresultsDatabaseSchema,outputPath = "c:/temp/SqlServer",cdmVersion=cdmVersion)
  
  #Test on PostgreSQL
  
  sqlServerresultsDatabaseSchema <- "cdm_truven_ccae_6k"
  schema <- "cdm_truven_ccae_6k"
  cdmVersion <- "4"
  
  sqlServerresultsDatabaseSchema <- "cdm_truven_ccae_6k_v5"
  schema <- "cdm_truven_ccae_6k_v5"
  cdmVersion <- "5"
  
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  exportToJson(connectionDetails, cdmDatabaseSchema = schema, resultsDatabaseSchema = "scratch",outputPath = "c:/temp/PostgreSQL",cdmVersion=cdmVersion)

  #Test on Oracle
  setwd("c:/temp")
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="oracle", server="xe", user="system",password="OHDSI")
  exportToJson(connectionDetails, cdmDatabaseSchema = schema, resultsDatabaseSchema = "scratch",outputPath = "c:/temp/Oracle",cdmVersion=cdmVersion)  
  
  #Compare JSON files:
  loadTextFile <- function(fileName){
    readChar(fileName, file.info(fileName)$size)
  }
  
  compareJSONFiles <- function(folder1,folder2){
    setwd(folder1)
    count <- 0
    for (f in list.files(pattern="*.\\.json",full.names=FALSE, recursive=TRUE)){
      count = count + 1
      file1 <- loadTextFile(paste(folder1,"/",f,sep=""))
      file2 <- loadTextFile(paste(folder2,"/",f,sep=""))
      
      file1 <- gsub("\"NA\"","\"\"",file1)
      file2 <- gsub("\"NA\"","\"\"",file2)
      if (nchar(file1) != nchar(file2)){
        writeLines(paste("Warning: size mismatch in",f))
      }
    }
    writeLines(paste("Finished comparing",count,"files"))
  }
  
  compareJSONFiles("c:/temp/oracle","c:/temp/postgresql")
  
  compareJSONFiles("c:/temp/postgresql","c:/temp/sqlserver")
  
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="oracle", server="xe", user="system", schema="scratch",password=pw)
  conn <- DatabaseConnector::connect(connectionDetails)
  analysesDetails <- dbGetQuery(conn,"SELECT * FROM ACHILLES_ANALYSiS")
  save(analysesDetails,"c:/temp/analysesDetails.rda")
  DatabaseConnector::dbDisconnect(conn)
}



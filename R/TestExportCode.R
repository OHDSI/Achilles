# some more test-code

testExportCode <- function(){
  
  pw <- ""
  
  #Test on SQL Server
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/SqlServer")
  #exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/SqlServer",reports = c("PROCEDURE"))
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/PostgreSQL")
  #exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/PostgreSQL", reports = c("DRUG"))
  
  #Test on PostgreSQL sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim_sample", resultsSchema = "scratch_sample",outputPath = "c:/temp/PostgreSQL_sample")
  #exportToJson(connectionDetails, cdmSchema = "cdm4_sim_sample", resultsSchema = "scratch_sample",outputPath = "c:/temp/PostgreSQL_sample", report = c("CONDITION_ERA"))
  
  #Test on Oracle sample
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  exportToJson(connectionDetails, cdmSchema = "cdm4_sim", resultsSchema = "scratch",outputPath = "c:/temp/Oracle")  
  
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
  
  compareJSONFiles("c:/temp/oracle","c:/temp/postgresql_sample")
  
  compareJSONFiles("c:/temp/postgresql","c:/temp/sqlserver")
  
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system", schema="scratch",password=pw)
  conn <- connect(connectionDetails)
  analysesDetails <- dbGetQuery(conn,"SELECT * FROM ACHILLES_ANALYSiS")
  save(analysesDetails,"c:/temp/analysesDetails.rda")
  dbDisconnect(conn)
}



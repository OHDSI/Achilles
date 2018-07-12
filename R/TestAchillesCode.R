# some test-code

testAchillesCode <- function(){
  pw <- ""
  #sqlServerServer <- "myserver"
  #sqlServerResultsSchema <- "scratch"
  #schema <- "cdm4_sim"
  
  sqlServerServer <- "myserver"
  
  sqlServerResultsSchema <- "my_cdm.dbo"
  schema <- "my_cdm.dbo"
  cdmVersion <- "4"
  
  sqlServerResultsSchema <- "my_cdm_v5.dbo"
  schema <- "my_cdm_v5.dbo"
  cdmVersion <- "5"
  
  #Test on SQL Server:
  setwd("c:/temp")
  connectionDetailsSqlServer <- DatabaseConnector::createConnectionDetails(dbms="sql server", server=sqlServerServer)
  achillesResultsSqlServer <- achilles(connectionDetailsSqlServer, cdmDatabaseSchema=schema, resultsDatabaseSchema=sqlServerResultsSchema,cdmVersion=cdmVersion)

  
  
  sqlServerResultsSchema <- "my_cdm"
  schema <- "my_cdm"
  cdmVersion <- "4"
  
  schema <- "my_cdm_v5"
  cdmVersion <- "5"
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetailsPostgreSql <- DatabaseConnector::createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmDatabaseSchema=schema, resultsDatabaseSchema="scratch",cdmVersion=cdmVersion)
  
  #Test on Oracle
  setwd("c:/temp")
  connectionDetailsOracle <- DatabaseConnector::createConnectionDetails(dbms="oracle", server="xe", user="system",password="OHDSI2")
  achillesResultsOracle <- achilles(connectionDetailsOracle, cdmDatabaseSchema=schema, oracleTempSchema = "temp", resultsDatabaseSchema="scratch",cdmVersion=cdmVersion)
  

  #Compare results:
  compareResults <- function(connection1, connection2){
    data(analysesDetails)
    writeLines("Comparing results table")
    for (analysis_id in analysesDetails$ANALYSIS_ID){
      x <- dbGetQuery(connection1,paste("SELECT * FROM ACHILLES_results WHERE analysis_id =",analysis_id))
      if (nrow(x) > 0){
        colnames(x) <- toupper(colnames(x))
        x <- x[with(x,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
        x[is.na(x)] <- ""
      }
      y <- dbGetQuery(connection2,paste("SELECT * FROM ACHILLES_results WHERE analysis_id =",analysis_id))
      if (nrow(y) > 0){
        colnames(y) <- toupper(colnames(y))
        y <- y[with(y,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
        y[is.na(y)] <- ""
      }
      if (!(nrow(x) == 0 && nrow(y) == 0)){
        x <- round(signif(x[sapply(x,FUN=is.numeric)],5),5)
        y <- round(signif(y[sapply(y,FUN=is.numeric)],5),5)
        if (nrow(x) != nrow(y)){
          writeLines(paste("Difference detected for analysisId",analysis_id))
        } else if (min(x==y) == 0){
          writeLines(paste("Difference detected for analysisId",analysis_id))
          if (analysis_id %in% c(818)){
            writeLines("(This was expected)")
          }else {
            count = 0
            for (r in 1:nrow(x)){
              if (min(x[r,] == y[r,]) == 0){
                col <- which(x[r,] != y[r,])
                writeLines(paste("Difference in",colnames(x)[col],":",x[r,col],"versus",y[r,col]))
                count = count + 1
                if (count == 10){
                  writeLines("...")
                  break;
                }
              }
            }
          }
        }        
      }  
    }
    
    writeLines("Comparing results_dist table")
    for (analysis_id in analysesDetails$ANALYSIS_ID){
      x <- dbGetQuery(connection1,paste("SELECT * FROM ACHILLES_results_dist WHERE analysis_id =",analysis_id))
      if (nrow(x) > 0){
        colnames(x) <- toupper(colnames(x))
        x <- x[with(x,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
        x[is.na(x)] <- ""
      }
      
      y <- dbGetQuery(connection2,paste("SELECT * FROM ACHILLES_results_dist WHERE analysis_id =",analysis_id))
      if (nrow(y) > 0){
        colnames(y) <- toupper(colnames(y))
        y <- y[with(y,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
        y[is.na(y)] <- ""
      }
      if (!(nrow(x) == 0 && nrow(y) == 0)){
        #STRATUM_1 <- y$STRATUM_1
        x <- round(signif(x[sapply(x,FUN=is.numeric)],5),5)
        y <- round(signif(y[sapply(y,FUN=is.numeric)],5),5)
        if (nrow(x) != nrow(y)){
          writeLines(paste("Difference detected for analysisId",analysis_id))
        } else if (min(x==y) == 0){
          writeLines(paste("Difference detected for analysisId",analysis_id))
          count = 0
          for (r in 1:nrow(x)){
            if (min(x[r,] == y[r,]) == 0){
              col <- which(x[r,] != y[r,])
              #writeLines(paste("Difference in",colnames(x)[col],":",x[r,col],"versus",y[r,col]," (STRATUM_1:",STRATUM_1[r],")"))
              writeLines(paste("Difference in",colnames(x)[col],":",x[r,col],"versus",y[r,col]))
              count = count + 1
              if (count == 10){
                writeLines("...")
                break;
              }
            }
          }        
        }
      }
    }  
  }
  
  #Compare Sql Server and Postgres:
  connectionDetailsSqlServer$schema = sqlServerResultsSchema
  connSqlServer <- DatabaseConnector::connect(connectionDetailsSqlServer)
  
  connectionDetailsPostgreSql$schema = "scratch"
  connPostgreSql <- DatabaseConnector::connect(connectionDetailsPostgreSql)
  
  compareResults(connSqlServer,connPostgreSql)
  
  #Compare Sql Server and Oracle:
  connectionDetailsSqlServer$schema = sqlServerResultsSchema
  connSqlServer <- DatabaseConnector::connect(connectionDetailsSqlServer)
  
  connectionDetailsOracle$schema = "scratch"
  connOracle <- DatabaseConnector::connect(connectionDetailsOracle)
  
  compareResults(connOracle,connSqlServer)
  #Note: differences will be found for 1411,1412 because of reverse sorting of dates due to different formats
}
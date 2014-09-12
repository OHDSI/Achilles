# some test-code

testAchillesCode <- function(){
  
  pw <- ""
  
  #Test on SQL Server:
  setwd("c:/temp")
  connectionDetailsSqlServer <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  achillesResultsSqlServer <- achilles(connectionDetailsSqlServer, cdmSchema="cdm4_sim", resultsSchema="scratch")
  
  #achillesResultsSqlServer <- achilles(connectionDetailsSqlServer, cdmSchema="cdm4_sim", resultsSchema="scratch", analysisIds=c(606),createTable=FALSE)
  
  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetailsPostgreSql <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim", resultsSchema="scratch")
  
  #achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim", resultsSchema="scratch",analysisIds=c(600:620),createTable = FALSE)
  
  #fetchAchillesAnalysisResults(connectionDetailsPostgreSql, "scratch", 606)
  
  #Test on PostgreSQL using sample
  setwd("c:/temp")
  connectionDetailsPostgreSql <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim_sample", resultsSchema="scratch_sample")
  
  #achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim_sample", resultsSchema="scratch_sample", analysisIds=c(116),createTable=FALSE)
  
  
  #Test on Oracle using sample:
  setwd("c:/temp")
  connectionDetailsOracle <- createConnectionDetails(dbms="oracle", server="xe", user="system",password="OHDSI")
  achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch")
  
  #achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch", analysisIds=c(116),createTable=FALSE)
  
  #fetchAchillesAnalysisResults(connectionDetailsPostgreSql, "scratch", 606)
  
  
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
            for (r in 1:nrow(x)){
              if (min(x[r,] == y[r,]) == 0){
                col <- which(x[r,] != y[r,])
                writeLines(paste("Difference in",colnames(x)[col],":",x[r,col],"versus",y[r,col]))
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
        x <- round(signif(x[sapply(x,FUN=is.numeric)],5),5)
        y <- round(signif(y[sapply(y,FUN=is.numeric)],5),5)
        if (nrow(x) != nrow(y)){
          writeLines(paste("Difference detected for analysisId",analysis_id))
        } else if (min(x==y) == 0){
          writeLines(paste("Difference detected for analysisId",analysis_id))
          for (r in 1:nrow(x)){
            if (min(x[r,] == y[r,]) == 0){
              col <- which(x[r,] != y[r,])
              writeLines(paste("Difference in",colnames(x)[col],":",x[r,col],"versus",y[r,col]))
            }
          }        
        }
      }
    }  
  }
  
  #Compare on full set:
  connectionDetailsSqlServer$schema = "scratch"
  connSqlServer <- connect(connectionDetailsSqlServer)
  
  connectionDetailsPostgreSql$schema = "scratch"
  connPostgreSql <- connect(connectionDetailsPostgreSql)
  
  compareResults(connSqlServer,connPostgreSql)
  
  #Compare on sample set:
  connectionDetailsOracle$schema = "scratch"
  connOracle <- connect(connectionDetailsOracle)
  
  connectionDetailsPostgreSql$schema = "scratch_sample"
  connPostgreSql <- connect(connectionDetailsPostgreSql)
  
  compareResults(connOracle,connPostgreSql)
  
}
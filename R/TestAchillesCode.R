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

  
  #Test on PostgreSQL using sample
  setwd("c:/temp")
  connectionDetailsPostgreSql <- createConnectionDetails(dbms="postgresql", server="localhost/ohdsi", user="postgres",password=pw)
  achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim_sample", resultsSchema="scratch_sample")

  #achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim_sample", resultsSchema="scratch_sample", analysisIds=c(606),createTable=FALSE)
  
  
  #Test on Oracle using sample:
  setwd("c:/temp")
  connectionDetailsOracle <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch")
  
  #achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch", analysisIds=c(606),createTable=FALSE)
  
  
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
        if (nrow(x) != nrow(y)){
          writeLines(paste("Difference detected for analysisId",analysis_id))
        } else if (min(signif(x[sapply(x,FUN=is.numeric)],3) ==signif(y[sapply(y,FUN=is.numeric)],3)) == 0){
          writeLines(paste("Difference detected for analysisId",analysis_id))
          #break
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
        if (nrow(x) != nrow(y)){
          writeLines(paste("Difference detected for analysisId",analysis_id))
        } else if (min(signif(x[sapply(x,FUN=is.numeric)],3) ==signif(y[sapply(y,FUN=is.numeric)],3)) == 0){
          writeLines(paste("Difference detected for analysisId",analysis_id))
          #break
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
  
  
  
  
  for (i in 1:nrow(x)){
    p <- x[i,]
    q <- y[i,]
    if (min(signif(as.numeric(p[sapply(p,FUN=is.numeric) & !is.na(p)]),3) ==signif(as.numeric(q[sapply(q,FUN=is.numeric) & !is.na(q)]),3)) == 0){
      writeLines(paste("Difference detected for analysisId",analysis_id))
      break
    }
  }
}
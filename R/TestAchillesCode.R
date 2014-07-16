# some test-code

testAchillesCode <- function(){

  pw <- " "
  
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
  
  achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="cdm4_sim_sample", resultsSchema="scratch_sample", analysisIds=c(116),createTable=FALSE)
  
  
  #Test on Oracle using sample:
  setwd("c:/temp")
  connectionDetailsOracle <- createConnectionDetails(dbms="oracle", server="xe", user="system",password=pw)
  achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch")
  
  achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch", analysisIds=c(116),createTable=FALSE)
  
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
        if (nrow(x) != nrow(y)){
          writeLines(paste("Difference detected for analysisId",analysis_id))
        } else if (min(round(signif(x[sapply(x,FUN=is.numeric)],5),5) == round(signif(y[sapply(y,FUN=is.numeric)],5),5)) == 0){
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
        } else if (min(round(signif(x[sapply(x,FUN=is.numeric)],5),5) == round(signif(y[sapply(y,FUN=is.numeric)],5),5)) == 0){
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
  
  x1 <- fetchAchillesAnalysisResults(connectionDetailsSqlServer, resultsSchema = "scratch", analysisId = 1510)
  x2 <- fetchAchillesAnalysisResults(connectionDetailsPostgreSql, resultsSchema = "scratch", analysisId = 1510)
  
  x1 <- dbGetQuery(connSqlServer,"SELECT * FROM achilles_results WHERE analysis_id = 1411")
  x2 <- dbGetQuery(connPostgreSql,"SELECT * FROM achilles_results WHERE analysis_id = 1411")
  colnames(x1) <- toupper(colnames(x1))
  x1 <- x1[with(x1,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
  colnames(x2) <- toupper(colnames(x2))
  x2 <- x2[with(x2,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
  head(x1)
  head(x2)
  xn1 <- round(signif(x1[sapply(x1,FUN=is.numeric)],3),3)
  xn2 <- round(signif(x2[sapply(x2,FUN=is.numeric)],3),3)
  sum(xn1 != xn2)
  for (r in 1:nrow(xn1)){
    if (min(xn1[r,] == xn2[r,]) == 0){
      print(r)
    }
  }

  xn1[2904,]
  xn2[2904,]
  xn1[2382,] == xn2[2382,]
  is.numeric(xn1[2095,5])
  is.numeric(xn2[2095,5])
  write.csv(x1,"c:/temp/x1.csv",row.names=FALSE)
  write.csv(x2,"c:/temp/x2.csv",row.names=FALSE)
  
  #Compare on sample set:
  connectionDetailsOracle$schema = "scratch"
  connOracle <- connect(connectionDetailsOracle)
  
  connectionDetailsPostgreSql$schema = "scratch_sample"
  connPostgreSql <- connect(connectionDetailsPostgreSql)
  
  compareResults(connOracle,connPostgreSql)
  
  x1 <- dbGetQuery(connOracle,"SELECT * FROM achilles_results WHERE analysis_id = 1411")
  x2 <- dbGetQuery(connPostgreSql,"SELECT * FROM achilles_results WHERE analysis_id = 1411")
  colnames(x1) <- toupper(colnames(x1))
  x1 <- x1[with(x1,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
  colnames(x2) <- toupper(colnames(x2))
  x2 <- x2[with(x2,order(STRATUM_1,STRATUM_2,STRATUM_3,STRATUM_4,STRATUM_5)),]
  head(x1)
  head(x2)
  xn1 <- round(signif(x1[sapply(x1,FUN=is.numeric)],3),3)
  xn2 <- round(signif(x2[sapply(x2,FUN=is.numeric)],3),3)
  sum(xn1 != xn2)
  for (r in 1:nrow(xn1)){
    if (min(xn1[r,] == xn2[r,]) == 0){
      print(r)
    }
  }
  
  xn1[2904,]
  xn2[2904,]
  xn1[2382,] == xn2[2382,]
  is.numeric(xn1[2095,5])
  is.numeric(xn2[2095,5])
  write.csv(x1,"c:/temp/x1.csv",row.names=FALSE)
  write.csv(x2,"c:/temp/x2.csv",row.names=FALSE)
  
  
  
  for (i in 1:nrow(x)){
    p <- x[i,]
    q <- y[i,]
    if (min(signif(as.numeric(p[sapply(p,FUN=is.numeric) & !is.na(p)]),3) ==signif(as.numeric(q[sapply(q,FUN=is.numeric) & !is.na(q)]),3)) == 0){
      writeLines(paste("Difference detected for analysisId",analysis_id))
      break
    }
  }
}
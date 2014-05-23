# some test-code

testCode <- function(){
  #Test on SQL Server:
  setwd("c:/temp")
  connectionDetailsSqlServer <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  achillesResultsSqlServer <- achilles(connectionDetailsSqlServer, cdmSchema="cdm4_sim", resultsSchema="scratch")

  #Test on Oracle:
  setwd("c:/temp")
  connectionDetailsOracle <- createConnectionDetails(dbms="oracle", server="xe", user="system",password="xxx")
  achillesResultsOracle <- achilles(connectionDetailsOracle, cdmSchema="cdm4_sim", resultsSchema="scratch")

  #Test on PostgreSQL
  setwd("c:/temp")
  connectionDetailsPostgreSql <- createConnectionDetails(dbms="postgresql", server="localhost/cdm4_sim", user="postgres",password="F1r3starter")
  achillesResultsPostgreSql <- achilles(connectionDetailsPostgreSql, cdmSchema="public", resultsSchema="scratch")
  
  #Compare results:
  analysis_id = 109
  connectionDetailsSqlServer$schema = "scratch"
  connSqlServer <- connect(connectionDetailsSqlServer)
  
  connectionDetailsPostgreSql$schema = "scratch"
  connPostgreSql <- connect(connectionDetailsPostgreSql)
  
  for (analysis_id in all_analysis_ids){
    x <- dbGetQuery(connSqlServer,paste("SELECT * FROM scratch.dbo.ACHILLES_results WHERE analysis_id =",analysis_id))
    x <- x[with(x,order(stratum_1,stratum_2,stratum_3,stratum_4,stratum_5)),]
    
    y <- dbGetQuery(connPostgreSql,paste("SELECT * FROM scratch.ACHILLES_results WHERE analysis_id =",analysis_id))
    y <- y[with(y,order(stratum_1,stratum_2,stratum_3,stratum_4,stratum_5)),]
    if (min(x[!is.na(x)] == y[!is.na(y)]) == 0){
      writeLines(paste("Difference detected for analysisId",analysisId))
      break
    }
  }
  
  for (analysis_id in all_analysis_ids){
    x <- dbGetQuery(connSqlServer,paste("SELECT * FROM scratch.dbo.ACHILLES_results_dist WHERE analysis_id =",analysis_id))
    x <- x[with(x,order(stratum_1,stratum_2,stratum_3,stratum_4,stratum_5)),]
    
    y <- dbGetQuery(connPostgreSql,paste("SELECT * FROM scratch.ACHILLES_results_dist WHERE analysis_id =",analysis_id))
    y <- y[with(y,order(stratum_1,stratum_2,stratum_3,stratum_4,stratum_5)),]
    if (min(signif(as.numeric(x[sapply(x,FUN=is.numeric) & !is.na(x)]),3) ==signif(as.numeric(y[sapply(y,FUN=is.numeric) & !is.na(y)]),3)) == 0){
      writeLines(paste("Difference detected for analysisId",analysis_id))
      #break
    }
  }
  
  
  for (i in 1:nrow(x)){
    p <- x[i,]
    q <- y[i,]
    if (min(signif(as.numeric(p[sapply(p,FUN=is.numeric) & !is.na(p)]),3) ==signif(as.numeric(q[sapply(q,FUN=is.numeric) & !is.na(q)]),3)) == 0){
      writeLines(paste("Difference detected for analysisId",analysis_id))
      break
    }
  }
  
  
}
# some test-code

testCode <- function(){
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  achillesResults <- achilles(connectionDetails, cdmSchema="cdm4_sim", resultsSchema="scratch")
  write.table(achillesResults$sql, file="c:/temp/ach.sql")
  
  
  write.table(error$sql,"c:/temp/problem.sql")
  
  
  
  
  sql <- read.table("c:/temp/rendered.sql")
  y <- splitSql(as.character(sql$x))
  for (i in 1:length(y)){
    write.table(y[i], file = paste("c:/temp/sql_",i,".sql",sep=""))
  }
  
  
  sql <- read.table("c:/temp/sql_28.sql")
  y <- splitSql(as.character(sql$x))
  str(y)
}
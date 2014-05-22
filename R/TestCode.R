# some test-code

testCode <- function(){
  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="sql server", server="RNDUSRDHIT07.jnj.com")
  achillesResults <- achilles(connectionDetails, cdmSchema="cdm4_sim", resultsSchema="scratch")


  setwd("c:/temp")
  connectionDetails <- createConnectionDetails(dbms="oracle", server="xe", user="system",password="xxx")
  achillesResults <- achilles(connectionDetails, cdmSchema="cdm4_sim", resultsSchema="scratch")

}
Make sure you have Impala running on a cluster with the Common Data Model data loaded
as described in [https://github.com/OHDSI/CommonDataModel/tree/master/Impala](https://github.com/OHDSI/CommonDataModel/tree/master/Impala).

Before running Achilles, create a database for the Achilles tables:

```bash
impala-shell -q 'CREATE DATABASE achilles'
```

In R, use the following commands to install the Impala development version of Achilles. I used Docker to get all the pre-reqs (and ran `docker run -it --rm achilles_achilles bash`).

```r
install.packages("devtools")
library(devtools)

install_github("tomwhite/SqlRender", ref="impala")
library(SqlRender)

install_github("tomwhite/DatabaseConnector", ref="impala")
library(DatabaseConnector)
cp <- c( 
"/usr/local/lib/R/site-library/DatabaseConnector/java/TCLIServiceClient.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/commons-codec-1.3.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/commons-logging-1.1.1.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/hive_metastore.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/hive_service.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/httpclient-4.1.3.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/httpcore-4.1.3.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/libfb303-0.9.0.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/libthrift-0.9.0.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/log4j-1.2.14.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/ql.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/slf4j-api-1.5.11.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/slf4j-log4j12-1.5.11.jar",
"/usr/local/lib/R/site-library/DatabaseConnector/java/zookeeper-3.4.6.jar"
)
.jinit(classpath=cp)

install_github("tomwhite/Achilles", ref="impala") 
```

To run Achilles for a single, simple analysis, try:

```r
library(Achilles)
connectionDetails <- createConnectionDetails(dbms="impala", 
                                             server="bottou01.sjc.cloudera.com",
                                             schema="omop_cdm")
achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="omop_cdm",
                            resultsDatabaseSchema="achilles", sourceName="Impala trial", deleteFromTable = FALSE, runHeel = FALSE,
                            cdmVersion = "5", vocabDatabaseSchema="omop_cdm", analysisIds = c(1))
```

Note the use of `deleteFromTable` for Impala (which can't delete rows from a table for non-Kudu storage).

Have a look at the output:

```bash
impala-shell -q 'select * from achilles.achilles_results'
```

The following is a more complex analysis:

```r
achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="omop_cdm",
                            resultsDatabaseSchema="achilles", sourceName="Impala trial", deleteFromTable = FALSE, runHeel = FALSE,
                            cdmVersion = "5", vocabDatabaseSchema="omop_cdm", analysisIds = c(105))
```

You can uninstall packages with 
```r
remove.packages("Achilles")
remove.packages("DatabaseConnector")
remove.packages("SqlRender")
```

If you want to delete all the Achilles results use the following:

```bash
impala-shell -q 'drop database achilles cascade'
```
Make sure you have Impala running on a cluster with the Common Data Model data loaded
as described in [https://github.com/OHDSI/CommonDataModel/tree/master/Impala](https://github.com/OHDSI/CommonDataModel/tree/master/Impala).

Before running Achilles, create a database for the Achilles tables:

```bash
impala-shell -q 'CREATE DATABASE achilles'
```

Download the Impala JDBC drivers from the [Cloudera website](http://www.cloudera.com/downloads/connectors/impala/jdbc/2-5-36.html), and install them in a local 
directory called _~/impala-drivers/Cloudera_ImpalaJDBC4_2.5.36_.

In R, use the following commands to install the Impala development version of Achilles. I used Docker to get all the pre-reqs (and ran `docker run -it --rm -v ~/impala-drivers/:/impala-drivers achilles_achilles bash`).

```r
install.packages("devtools")
                 library(devtools)

install_github("tomwhite/SqlRender", ref="impala-timestamp")
library(SqlRender)
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/Achilles")
```

To run Achilles for a single, simple analysis, try:

```r
library(Achilles)
connectionDetails <- createConnectionDetails(dbms="impala", 
                                             server="bottou01.sjc.cloudera.com",
                                             schema="omop_cdm_parquet",
                                             pathToDriver = "/impala-drivers/Cloudera_ImpalaJDBC4_2.5.36")
achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="omop_cdm_parquet",
                            resultsDatabaseSchema="achilles", sourceName="Impala trial", runHeel = FALSE,
                            cdmVersion = "5", vocabDatabaseSchema="omop_cdm_parquet", analysisIds = c(1))
```

Have a look at the output:

```bash
impala-shell -q 'select * from achilles.achilles_results'
```

The following is a more complex analysis:

```r
achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="omop_cdm_parquet",
                            resultsDatabaseSchema="achilles", sourceName="Impala trial", runHeel = FALSE,
                            cdmVersion = "5", vocabDatabaseSchema="omop_cdm_parquet", analysisIds = c(105))
```

This is how you can run a set of analyses, by exclusion:
```r
allAnalyses=getAnalysisDetails()$analysis_id
subset1=setdiff(allAnalyses,c(110))
subset2=Filter(function(X) { X > 0 }, subset1)
achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="omop_cdm_parquet",
                            resultsDatabaseSchema="achilles", sourceName="Impala trial", runHeel = FALSE, createTable = FALSE,
                            cdmVersion = "5", vocabDatabaseSchema="omop_cdm_parquet", 
                            analysisIds = subset2)
```

Note that `createTable` has been set to `FALSE` so that the initial tables are not 
created, to save time.

Finally, run all of the analyses with:

```r
achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="omop_cdm_parquet",
                            resultsDatabaseSchema="achilles", sourceName="Impala trial", runHeel = FALSE,
                            cdmVersion = "5", vocabDatabaseSchema="omop_cdm_parquet")
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


Heel implementation for Impala

Currently only Achilles precomputations are fully developed for Impala. No work was done on the Heel component of Achilles

```bash
impala-shell -q 'drop database achilles cascade'
```
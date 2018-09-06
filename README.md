Achilles
========

[![Build Status](https://travis-ci.org/OHDSI/Achilles.svg?branch=master)](https://travis-ci.org/OHDSI/Achilles)
[![codecov.io](https://codecov.io/github/OHDSI/Achilles/coverage.svg?branch=master)](https://codecov.io/github/OHDSI/Achilles?branch=master)
 
**A**utomated **C**haracterization of **H**ealth **I**nformation at **L**arge-scale **L**ongitudinal **E**vidence **S**ystems (ACHILLES)---descriptive statistics and data quality checks on an OMOP CDM v5 databases

Achilles consists of several parts: 

1. Precomputations (for database characterization) 

1. Achilles Heel for data quality

1. Export feature for AchillesWeb (or, Atlas Data Sources can read the Achilles tables directly)

1. Index generation for better performance with Atlas Data Sources

Achilles is actively being developed for CDM v5.x only.

## Getting Started

(Please review the [Achilles Wiki](https://github.com/OHDSI/Achilles/wiki/Additional-instructions-for-Linux) for specific details for Linux)

1. Make sure you have your data in the OMOP CDM v5.x format
    (https://github.com/OHDSI/CommonDataModel).

1. This package makes use of rJava. Make sure that you have Java installed. If you don't have Java already installed on your computer (on most computers it already is installed), go to [java.com](https://java.com) to get the latest version. If you are having trouble with rJava, [this Stack Overflow post](https://stackoverflow.com/questions/7019912/using-the-rjava-package-on-win7-64-bit-with-r) may assist you when you begin troubleshooting.


1. In R, use the following commands to install Achilles.

    ```r
    if (!require("devtools")) install.packages("devtools")
    
    # To install the master branch
    devtools:: install_github("OHDSI/Achilles")
    
    # To install latest release (if master branch contains a bug for you)
    # devtools::install_github("OHDSI/Achilles@*release")  
    
    # To avoid Java 32 vs 64 issues 
    # devtools::install_github("OHDSI/Achilles", args="--no-multiarch")  
    ```

1. To run the Achilles analysis, first determine if you'd like to run the function in multi-threaded mode or in single-threaded mode. Use `runCostAnalysis = FALSE` to save on execution time, as cost analyses tend to run long.
    
    **In multi-threaded mode**
    
    The analyses are run in multiple SQL sessions, which can be set using the `numThreads` setting and setting scratchDatabaseSchema to something other than `#`. For example, 10 threads means 10 independent SQL sessions. Intermediate results are written to scratch tables before finally being combined into the final results tables. Scratch tables are permanent tables; you can either choose to have Achilles drop these tables (`dropScratchTables = TRUE`) or you can drop them at a later time (`dropScratchTables = FALSE`). Dropping the scratch tables can add time to the full execution. If desired, you can set your own custom prefix for all Achilles analysis scratch tables (tempAchillesPrefix) and/or for all Achilles Heel scratch tables (tempHeelPrefix).
    
    **In single-threaded mode**
    
    The analyses are run in one SQL session and all intermediate results are written to temp tables before finally being combined into the final results tables. Temp tables are dropped once the package is finished running. Single-threaded mode can be invoked by either setting `numThreads = 1` or `scratchDatabaseSchema = "#"`.
    
    Use the following commands in R: 
  
    ```r
    library(Achilles)
    connectionDetails <- createConnectionDetails(
      dbms="redshift", 
      server="server.com", 
      user="secret", 
      password='secret', 
      port="5439")
    ```
    
    **Single-threaded mode**
    
    ```r
    achilles(connectionDetails, 
      cdmDatabaseSchema = "cdm5_inst", 
      resultsDatabaseSchema="results",
      vocabDatabaseSchema = "vocab",
      numThreads = 1,
      sourceName = "My Source Name", 
      cdmVersion = "5.3.0",
      runHeel = TRUE,
      runCostAnalysis = TRUE)
    ```

    **Multi-threaded mode**
    
    ```r
    achilles(connectionDetails, 
      cdmDatabaseSchema = "cdm5_inst", 
      resultsDatabaseSchema = "results",
      scratchDatabaseSchema = "scratch",
      vocabDatabaseSchema = "vocab",
      numThreads = 10,
      sourceName = "My Source Name", 
      cdmVersion = "5.3.0",
      runHeel = TRUE,
      runCostAnalysis = TRUE)
    ```
    
    The `"cdm5_inst"` cdmDatabaseSchema parameter, `"results"` resultsDatabaseSchema parameter, and `"scratch"` scratchDatabaseSchema parameter are the fully qualified names of the schemas holding the CDM data, targeted for result writing, and holding the intermediate scratch tables, respectively. See the [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector) package for details on settings the connection details for your database, for example by typing
      
    ```r
    ?createConnectionDetails
    ```

    Execution of all Achilles pre-computations may take a long time, particularly in single-threaded mode and with COST analyses enabled. See <extras/notes.md> file to find out how some analyses can be excluded to make the execution faster (excluding cost pre-computations) 
      
    Currently `"sql server"`, `"pdw"`, `"oracle"`, `"postgresql"`, `"redshift"`, `"mysql"`, `"impala"`, and `"bigquery"` are supported as `dbms`. `cdmVersion` can be *ONLY* 5.x (please look at prior commit history for v4 support).

1. To use [AchillesWeb](https://github.com/OHDSI/AchillesWeb) to explore the Achilles statistics, you must first export the statistics to a folder JSON files, which can optionally be compressed into one gzipped file for easier transportability.

    ```r
    exportToJson(connectionDetails, 
      cdmDatabaseSchema = "cdm5_inst", 
      resultsDatabaseSchema = "results", 
      outputPath = "c:/myPath/AchillesExport", 
      cdmVersion = "5.3.0",
      compressIntoOneFile = TRUE # creates gzipped file of all JSON files)
    ```

1. To run only Achilles Heel (component of Achilles), use the following command:

    ```r
    achillesHeel(connectionDetails, 
      cdmDatabaseSchema = "cdm5_inst", 
      resultsDatabaseSchema = "results", 
      scratchDatabaseSchema = "scratch",
      numThreads = 10, # multi-threaded mode
      cdmVersion = "5.3.0")
    ```

1. Possible optional additional steps:

    - To see what errors were found (from within R), run:
        ```r
        fetchAchillesHeelResults(connectionDetails,resultsDatabaseSchema)
        ```
    - To see a particular analysis, run:
        ```r
        fetchAchillesAnalysisResults(connectionDetails,resultsDatabaseSchema,analysisId = 2)
        ```
    - To join data tables with some lookup (overview files), obtain those using commands below:
    - To get description of analyses, run `getAnalysisDetails()`.
    - To get description of derived measures, run:
        ```r
        read.csv(system.file("csv","derived_analysis_details",package="Achilles"),as.is=T)
        ```
    - Similarly, for overview of rules, run:
        ```r
        read.csv(system.file("csv","achilles_rule.csv",package="Achilles"),as.is=T)
        ```
    - Also see [notes.md](extras/notes.md) for more information (in the extras folder).

## Developers: How to Add or Modify Analyses

Please refer to the [README-developers.md file](README-developers.md).

## Getting Started with Docker

This is an alternative method for running Achilles that does not require R and Java installations, using a Docker container instead.

1. Install [Docker](https://docs.docker.com/installation/) and [Docker Compose](https://docs.docker.com/compose/install/).

1. Clone this repository with git (`git clone https://github.com/OHDSI/Achilles.git`) and make it your working directory (`cd Achilles`).

3. Copy *`env_vars.sample`* to *`env_vars`* and fill in the variable definitions. The `ACHILLES_DB_URI` should be formatted as `<dbms>://<username>:<password>@<host>/<schema>`.

4. Copy *`docker-compose.yml.sample`* to *`docker-compose.yml`* and fill in the data output directory.

5. Build the docker image with `docker-compose build`.

6. Run Achilles in the background with `docker-compose run -d achilles`.

Alternatively, you can run it with one long command line, like in the following example:

```bash
docker run \
  --rm \
  --net=host \
  -v "$(pwd)"/output:/opt/app/output \
  -e ACHILLES_SOURCE=DEFAULT \
  -e ACHILLES_DB_URI=postgresql://webapi:webapi@localhost:5432/ohdsi \
  -e ACHILLES_CDM_SCHEMA=cdm5 \
  -e ACHILLES_VOCAB_SCHEMA=cdm5 \
  -e ACHILLES_RES_SCHEMA=webapi \
  -e ACHILLES_CDM_VERSION=5 \
  <image name>
```

## License

Achilles is licensed under Apache License 2.0


## Pre-computations

Achilles has some compatibility with Data Quality initiatives of the Data Quality Collaborative (DQC; http://repository.edm-forum.org/dqc or GitHub https://github.com/orgs/DQCollaborative). For example, a harmonized set of data quality terms has been published by Khan at al. in 2016.

What Achilles calls an *analysis* (a pre-computation for a given dataset), the term used by DQC would be *measure*.

Some Heel Rules take advantage of derived measures. A feature of Heel introduced since version 1.4. A *derived measure* is a result of an SQL query that takes Achilles analyses as input. It is simply a different view of the precomputations that has some advantage to be materialized.  The logic for computing a derived measures can be viewed in the Heel SQL files in *`/inst/sql/sql_server/heels`*, which are described further in the [Developers README file](README-developers.md).

Overview of derived measures can be seen in [CSV file here](inst/csv/heel/heel_results_derived_details.csv).

For possible future flexible setting of Achilles Heel rule thresholds, some Heel rules are split into two phase approach. First, a derived measure is computed and the result is stored in a separate table `ACHILLES_RESULTS_DERIVED`. A Heel rule logic is than made simpler by a simple comparison whether a derived measure is over a threshold. A link between which rules use which pre-computation is available in [CSV file here](inst/csv/heel/heel_rules_all.csv)  (previously was in `inst/csv/achilles_rule.csv`) (see column `linked_measure`).


## Heel Rules

Rules are classified into `CDM conformance` rules and `DQ` rules - see column `rule_type` in the [CSV file here](inst/csv/heel/heel_rules_all.csv).


Some Heel rules can be generalized to non-OMOP datasets. Other rules are dependant on OMOP concept ids and a translation of the code to other CDMs would be needed (for example rule with `rule_id` of `29` uses OMOP specific concept;concept 195075).

Rules that have in their name a prefix `[GeneralPopulationOnly]` are applicable to datasets that represent a general population. Once metadata for this parameter is implemented by OHDSI, their execution can be limited to such datasets. In the meantime, users should ignore output of rules that are meant for general population if their dataset is not of that type.

Rules are classified into: error, warning and notification (see column `severity`).


## Acknowledgements
- This project is supported in part through the National Science Foundation grant IIS 1251151.

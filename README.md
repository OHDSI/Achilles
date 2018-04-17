Achilles
========
 
Automated Characterization of Health Information at Large-scale Longitudinal Evidence Systems (ACHILLES) - descriptive statistics and data quality checks on an OMOP CDM v5 databases

Achilles consists of several parts: 
1. Precomputations (for database characterization) 
2. Achilles Heel for data quality
3. Export feature for AchillesWeb
4. Index generation for better performance with Atlas Data Sources

Achilles is actively being developed for CDM v5.x only.

Getting Started
===============
(Please review the [Achilles Wiki](https://github.com/OHDSI/Achilles/wiki/Additional-instructions-for-Linux) for specific details for Linux)

1. Make sure you have your data in the OMOP CDM v4/v5.x format  (v4 link: http://omop.org/cdm, v5 link: https://github.com/OHDSI/CommonDataModel).

2. Make sure that you have Java installed. If you don't have Java already intalled on your computed (on most computers it already is installed), go to [java.com](http://java.com) to get the latest version.  (If you have trouble building with rJava below, be sure on Windows that your Path variable includes the path to jvm.dll: 

```Windows Button and R --> type "sysdm.cpl" --> Advanced tab --> Environmental Variables button --> Edit PATH variable, and then add to the end your Java Path (e.g. ';C:/Program Files/Java/jre/bin/server')```

3. In R, use the following commands to install Achilles (if you have prior package installations of any of these packages, you may need to first uninstall them using the command remove.packages()).

  ```r
  install.packages("devtools")
  library(devtools)
  install_github("OHDSI/SqlRender")
  install_github("OHDSI/DatabaseConnector")
  install_github("OHDSI/Achilles")
  #install_github("OHDSI/Achilles",args="--no-multiarch")  #to avoid Java 32 vs 64 issues 
  ```
  
4. To run the Achilles analysis, first determine if you'd like to run the function in multi-threaded mode or in single-threaded mode. Use 'runCostAnalysis = FALSE' to save on execution time, as cost analyses tend to run long.

**In multi-threaded mode**

The analyses are run in multiple SQL sessions, which can be set using the 'numThreads' setting and setting scratchDatabaseSchema to something other than '#'. For example, 10 threads means 10 independent SQL sessions. Intermediate results are written to scratch tables before finally being combined into the final results tables. Scratch tables are permanent tables; you can either choose to have Achilles drop these tables ('dropScratchTables = TRUE') or you can drop them at a later time ('dropScratchTables = FALSE'). Dropping the scratch tables can add time to the full execution. If desired, you can set your own custom prefix for all Achilles analysis scratch tables (tempAchillesPrefix) and/or for all Achilles Heel scratch tables (tempHeelPrefix).

**In single-threaded mode**

The analyses are run in one SQL session and all intermediate results are written to temp tables before finally being combined into the final results tables. Temp tables are dropped once the package is finished running. Single-threaded mode can be invoked by either setting 'numThreads = 1' or 'scratchDatabaseSchema = #'.


use the following commands in R: 

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
  
The "cdm5_inst" cdmDatabaseSchema parameter, "results" resultsDatabaseSchema parameter, and "scratch" scratchDatabaseSchema parameter are the fully qualified names of the schemas holding the CDM data, targeted for result writing, and holding the intermediate scratch tables, respectively. See the [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector) package for details on settings the connection details for your database, for example by typing
  
  ```r
  ?createConnectionDetails
  ```
  
Execution of all Achilles pre-computations may take a long time, particularly in single-threaded mode and with COST analyses enabled. See notes.md file to find out how some analyses can be excluded to make the execution faster (excluding cost pre-computations) 
  
Currently "sql server", "pdw", "oracle", "postgresql", "redshift", "mysql", "impala", and "bigquery" are supported as dbms. "cdmVersion" can be *ONLY* 5.x (please look at prior commit history for v4 support).

5. To use [AchillesWeb](https://github.com/OHDSI/AchillesWeb) to explore the Achilles statistics, you must first export the statistics to a folder JSON files, which can optionally be compressed into one gzipped file for easier transportability.
  ```r
  exportToJson(connectionDetails, 
    cdmDatabaseSchema = "cdm5_inst", 
    resultsDatabaseSchema = "results", 
    outputPath = "c:/myPath/AchillesExport", 
    cdmVersion = "5.3.0",
    compressIntoOneFile = TRUE # creates gzipped file of all JSON files)
  ```

6. To run only Achilles Heel (component of Achilles), use the following command:
  ```r
  achillesHeel(connectionDetails, 
    cdmDatabaseSchema = "cdm5_inst", 
    resultsDatabaseSchema = "results", 
    scratchDatabaseSchema = "scratch",
    numThreads = 10, # multi-threaded mode
    cdmVersion = "5.3.0")
  ```

7. Possible optional additional steps:

  - To see what errors were found (from within R), run `fetchAchillesHeelResults(connectionDetails,resultsDatabaseSchema)`

  - To see a particular analysis, run `fetchAchillesAnalysisResults(connectionDetails,resultsDatabaseSchema,analysisId = 2)`

  - To join data tables with some lookup (overview files), obtains those using commands below:

  - To get description of analyses, run `getAnalysisDetails()`.

  - To get description of derived measures, run `read.csv(system.file("csv","derived_analysis_details",package="Achilles"),as.is=T)`

  - Similarly, for overview of rules, run  
  
```read.csv(system.file("csv","achilles_rule.csv",package="Achilles"),as.is=T)```

    - Also see [notes.md](extras/notes.md) for more information (in the extras folder).


Getting Started with Docker
===========================
This is an alternative method for running Achilles that does not require R and Java installations, using a Docker container instead.

1. Install [Docker](https://docs.docker.com/installation/) and [Docker Compose](https://docs.docker.com/compose/install/).

2. Clone this repository with git (`git clone https://github.com/OHDSI/Achilles.git`) and make it your working directory (`cd Achilles`).

3. Copy `env_vars.sample` to `env_vars` and fill in the variable definitions. The `ACHILLES_DB_URI` should be formatted as `<dbms>://<username>:<password>@<host>/<schema>`.

4. Copy `docker-compose.yml.sample` to `docker-compose.yml` and fill in the data output directory.

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

License
=======
Achilles is licensed under Apache License 2.0


# Pre-computations

Achilles has some compatibility with Data Quality initiatives of the Data Quality Collaborative (DQC; http://repository.edm-forum.org/dqc or GitHub https://github.com/orgs/DQCollaborative). For example, a harmonized set of data quality terms has been published by Khan at al. in 2016.

What Achilles calls an *analysis* (a pre-computation for a given dataset), the term used by DQC would be *measure*

Some Heel Rules take advantage of derived measures. A feature of Heel introduced since version 1.4.  A *derived measure* is a result of an SQL query that takes Achilles analyses as input. It is simply a different view of the precomputations that has some advantage to be materialized.  The logic for computing a derived measures can be viewed in the `AchillesHeel_v5.sql` file.

Overview of derived measures can be seen in file `derived_analysis_details.csv`.

For possible future flexible setting of Achilles Heel rule thresholds, some Heel rules are split into two phase approach. First, a derived measure is computed and the result is stored in a separate table `ACHILLES_RESULTS_DERIVED`. A Heel rule logic is than made simpler by a simple comparison whether a derived measure is over a threshold. A link between which rules use which pre-computation is available in file `inst\csv\achilles_rule.csv` (see column `linked_measure`).


# Heel Rules

Rules are classified into `CDM conformance` rules and `DQ` rules (see column `rule_type` in the rule CSV file).


Some Heel rules can be generalized to non-OMOP datasets. Other rules are dependant on OMOP concept ids and a translation of the code to other CDMs would be needed (for example rule with `rule_id` of `29` uses OMOP specific concept;concept 195075).

Rules that have in their name a prefix `[GeneralPopulationOnly]` are applicable to datasets that represent a general population. Once metadata for this parameter is implemented by OHDSI, their execution can be limited to such datasets. In the meantime, users should ignore output of rules that are meant for general population if their dataset is not of that type.

Rules are classified into: error, warning and notification (see column `severity`).


Development
===========
Achilles is being developed in RStudio.

### Development status
[![Build Status](https://travis-ci.org/OHDSI/Achilles.svg?branch=master)](https://travis-ci.org/OHDSI/Achilles)
[![codecov.io](https://codecov.io/github/OHDSI/Achilles/coverage.svg?branch=master)](https://codecov.io/github/OHDSI/Achilles?branch=master)



# Acknowledgements
- This project is supported in part through the National Science Foundation grant IIS 1251151.

Achilles
========
 
Automated Characterization of Health Information at Large-scale Longitudinal Evidence Systems (ACHILLES) - descriptive statistics about a OMOP CDM v4/v5 database

Achilles consists of several parts: 1. precomputations (for database characterization) 2. Achilles Heel for data quality and 3. export feature for AchillesWeb

Achilles Heel is activelly being developed for CDM v5 only.

Getting Started
===============
(Please review the [Achilles Wiki](https://github.com/OHDSI/Achilles/wiki/Additional-instructions-for-Linux) for specific details for Linux)

1. Make sure you have your data in the OMOP CDM v4/v5 format  (v4 link http://omop.org/cdm v5 link:http://www.ohdsi.org/web/wiki/doku.php?id=documentation:cdm).

2. Make sure that you have Java installed. If you don't have Java already intalled on your computed (on most computers it already is installed), go to [java.com](http://java.com) to get the latest version.  (If you have trouble building with rJava below, be sure on Windows that your Path variable includes the path to jvm.dll (Windows Button --> type "path" --> Edit Environmental Variables --> Edit PATH variable, add to end ;C:/Program Files/Java/jre/bin/server) or wherever it is on your system.)

3. in R, use the following commands to install Achilles (if you have prior package installations of aony of these packages, you may need to first unistall them using the command remove.packages()).

  ```r
  install.packages("devtools")
  library(devtools)
  install_github("ohdsi/SqlRender")
  install_github("ohdsi/DatabaseConnector")
  install_github("ohdsi/Achilles")
  #install_github("OHDSI/Achilles",args="--no-multiarch")  #to avoid Java 32 vs 64 issues 
  #install_github("OHDSI/OhdsiRTools@v1.3.0")#use a prior released version (to bypass fresh errors)
  ```
  
4. To run the Achilles analysis, use the following commands in R: (use runCostAnalysis = F or runHeel = F if necessary)

  ```r
  library(Achilles)
  connectionDetails <- createConnectionDetails(dbms="redshift", server="server.com", user="secret",
                              password='secret', schema="cdm5_inst", port="5439")
  achillesResults <- achilles(connectionDetails, cdmDatabaseSchema="cdm5_inst", 
                              resultsDatabaseSchema="results", sourceName="My Source Name", 
                              cdmVersion = "cdm version", vocabDatabaseSchema="vocabulary")
  ```
  "cdm4_inst" cdmDatabaseSchema parmater, "results" resultsDatabaseSchema parameter, and "vocabulary" vocabDatabaseSchema are the names of the schemas holding the CDM data, targeted for result writing, and holding the Vocabulary data respectively. See the [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector) package for details on settings the connection details for your database, for example by typing
  
  Execution of all Achilles pre-computations may take a long time. See notes.md file to find out how some analyses can be excluded to make the execution faster (excluding cost pre-computations) 
  ```r
  ?createConnectionDetails
  ```
  Currently "sql server", "oracle", "postgresql", and "redshift" are supported as dbms.
  "cdmVersion" can be either 4 or 5 (note that some Achilles features are only implemented for version 5).

5. To use [AchillesWeb](https://github.com/OHDSI/AchillesWeb) to explore the Achilles statistics, you must first export the statistics to JSON files:
  ```r
  exportToJson(connectionDetails, cdmDatabaseSchema = "cdm4_inst", resultsDatabaseSchema = "results", outputPath = "c:/myPath/AchillesExport", cdmVersion = "cdm version", vocabDatabaseSchema = "vocabulary")
  ```

6. To run only Achilles Heel (component of Achilles), use the following command:
  ```r
  achillesHeel(connectionDetails, cdmDatabaseSchema = "cdm4_inst", resultsDatabaseSchema = "results", cdmVersion = "cdm version", vocabDatabaseSchema = "vocabulary")
  ```

7. Possible optional additional steps:

To see what errors were found (from within R), run `fetchAchillesHeelResults(connectionDetails,resultsDatabaseSchema)`

To see a particular analysis, run `fetchAchillesAnalysisResults(connectionDetails,resultsDatabaseSchema,analysisId = 2)`

To join data tables with some lookup (overview files), obtains those using commands below:

To get description of analyses, run `getAnalysisDetails()`.

To get description of derived measures, run `read.csv(system.file("csv","derived_analysis_details",package="Achilles"),as.is=T)`

Similarly, for overview of rules, run  
`read.csv(system.file("csv","achilles_rule.csv",package="Achilles"),as.is=T)`

Also see [notes.md](extras/notes.md) for more information (in the extras folder).


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
Achilles is being developed in R Studio.

### Development status
[![Build Status](https://travis-ci.org/OHDSI/Achilles.svg?branch=master)](https://travis-ci.org/OHDSI/Achilles)
[![codecov.io](https://codecov.io/github/OHDSI/Achilles/coverage.svg?branch=master)](https://codecov.io/github/OHDSI/Achilles?branch=master)



# Acknowledgements
- This project is supported in part through the National Science Foundation grant IIS 1251151.

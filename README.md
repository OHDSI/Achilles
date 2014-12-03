Achilles
========
 
Automated Characterization of Health Information at Large-scale Longitudinal Evidence Systems (ACHILLES) - descriptive statistics about a OMOP CDM v4 database

Getting Started
===============
(Please review the [Achilles Wiki](https://github.com/OHDSI/Achilles/wiki/Additional-instructions-for-Linux) for specific details for Linux)

1. Make sure you have your data in the [OMOP CDM v4 format](http://omop.org/cdm).

2. Make sure that you have Java installed. If you don't have Java already intalled on your computed (on most computers it already is installed), go to [java.com](http://java.com) to get the latest version.  (If you have trouble building with rJava below, be sure on Windows that your Path variable includes the path to jvm.dll (Windows Button --> type "path" --> Edit Environmental Variables --> Edit PATH variable, add to end ;C:/Program Files/Java/jre/bin/server) or wherever it is on your system.)

3. in R, use the following commands to install Achilles:

  ```r
  install.packages("devtools")
  library(devtools)
  install_github("ohdsi/DatabaseConnector")
  install_github("ohdsi/SqlRender")
  install_github("ohdsi/Achilles")
  ```
  
4. To run the Achilles analysis, use the following commands in R:

  ```r
  library(Achilles)
  connectionDetails <- createConnectionDetails(dbms="sql server", server="server.com")
  achillesResults <- achilles(connectionDetails, "cdm4_inst", "results")
  ```
  "cdm4_inst" and "results" are the names of the schemas holding the CDM data and target results respectively. See the [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector) package for details on settings the connection details for your database, for example by typing
  ```r
  ?createConnectionDetails
  ```
  Currently "sql server", "oracle", "postgresql", and "redshift" are supported as dbms.

5. To use [AchillesWeb](https://github.com/OHDSI/AchillesWeb) to explore the Achilles statistics, you must first export the statistics to JSON files:
  ```r
  exportToJson(connectionDetails, "cdm4_inst", "results", "c:/myPath/AchillesExport")
  ```

License
=======
Achilles is licensed under Apache License 2.0

# Acknowledgements
- This project is supported in part through the National Science Foundation grant IIS 1251151.

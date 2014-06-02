Achilles
========

Automated Characterization of Health Information at Large-scale Longitudinal Evidence Systems (ACHILLES) - descriptive statistics about a OMOP CDM v4 database

Getting Started
===============
1. Make sure you have your data in the [OMOP CDM v4 format](http://omop.org/cdm).
2. in R, use the following commands to install Achilles:
...R
install.packages("devtools")
library(devtools)
install_github("ohdsi/DatabaseConnector")
install_github("ohdsi/SqlRender")
install_github("ohdsi/Achilles")
...
3. To run the Achilles analysis, use the following commands in R:
...R
library(Achilles)
connectionDetails <- createConnectionDetails(dbms="sql server", server="server.com")
achillesResults <- achilles(connectionDetails, "cdm4_inst", "results")
...
"cdm4_inst" and "results" are the names of the schemas holding the CDM data and target results respectively. See the [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector) package for details on settings the connection details for your database, for example by typing
...R
?createConnectionDetails
...
Currently "sql server", "oracle" and "postgresql" are supported as dbms.
4. To use [AchillesWeb](https://github.com/OHDSI/AchillesWeb) to explore the Achilles statistics, you must first export the statistics to JSON files:
...R
exportToJson(connectionDetails, cdmSchema = "cdm4_inst", resultsSchema = "results",outputPath = "c:/myPath/AchillesExport")
...

License
=======
Achilles is licensed under Apache License 2.0

# Acknowledgements
- This project is supported in part through the National Science Foundation grant IIS 1251151.

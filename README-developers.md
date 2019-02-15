# Achilles Developer README

If you are interested in adding or modifying Achilles/Heel analyses, this is the section for you. A few key design principles:

1. All analyses are split into separate files. This allows us to parallelize them if possible by using the ParallelLogger clusterApply function, which allows for the spawning of multiple threads to process multiple list items. In this case, we have a list of analysis file names to process, before merging all of the staging tables into the final permanent tables as the last step.

2. All analysis queries must be optimized for MPP systems by including a hashing hint. Generally, this is person_id or subject_id, or whichever field offers a useful index. Please refer to the DatabaseConnector package for more information.

3. Main Achilles analyses (pre-computed aggregated stats about the data source) are stored in inst/analyses, Heel analyses (data quality checks about those aggregated stats) are stored in *inst/sql/sql_server/heels*, and export to JSON scripts are stored in *inst/sql/sql_server/exports*. Any post-processing activities such as index building and concept hierarchy table creation are stored in *inst/sql/sql_server/post_processing*.

## Achilles Main Analyses

* **inst/csv/schemas/schema_achilles_results.csv**: This file defines the schema for the main summary results.

* **inst/csv/schemas/schema_achilles_results_dist.csv**: This file defines the schema for the main distributed results.

* **inst/csv/achilles/achilles_analysis_details.csv**: This file outlines all of the main Achilles analyses, identified by analysis_id and analysis_name.

  + ANALYSIS_ID field
    - The identifier of each main Achilles analysis; this identifier corresponds to SQL file names.
    
  + DISTRIBUTION field
    - If the analysis provides distributed statistics, then DISTRIBUTION = 1
    - If it provides basic summary statistics, then DISTRIBUTION = 0
    - It it provides both, then DISTRIBUTION = -1

  + COST field
    - If the analysis is about the COST table, then COST = 1, else COST = 0

  + DISTRIBUTED_FIELD field
    - For cost analyses, the CDM field to analyze
    
  + ANALYSIS_NAME field
    - The full description of the analysis
    
  + STRATUM_1_NAME, STRATUM_2_NAME, STRATUM_3_NAME, STRATUM_4_NAME, STRATUM_5_NAME fields
    - CDM fields or conceptual values to stratify the analysis by
  
* **inst/csv/achilles/achilles_cost_columns.csv**: This file defines the cost table field names per domain.

  + OLD field
    - For CDM v5.0, these cost columns will be used, along with the older drug_cost and procedure_cost tables

  + CURRENT field
    - For CDM v5.1+, these cost columns will be used, along with the unified COST table

### How to Add a Main Achilles Analysis

To add a new analysis, you would need to define it in the analysis_details.csv and store it in a SQL file with the analysis_id as the name. The query must conform to either the achilles_results or achilles_results_dist schemas. If you'd like the analysis to write to both tables, include all pertinent queries in the file, and give the DISTRIBUTUON a value of -1. Remember to provide a hashing hint for the query so that MPP systems can benefit from the performance gain.

**Main Achilles Analysis SQL conventions**

Follow the conventions of existing analyses: `select <fields> into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_<analysis_id> from @cdmDatabaseSchema.<table>;`

* The `@scratchDatabaseSchema` parameter refers to the schema that will hold the staging table for this analysis.

* The `@schemaDelim` parameter refers to the delimiter used for this destination staging table (either 's_' or '.'). This is changed based upon whether the user is selecting single threaded or multi-threaded mode.

* The `@tempAchillesPrefix` parameter refers to the staging table prefix to use for each staging table ('tmpach' by default, or whatever the user provides).

* The `@cdmDatabaseSchema` parameter refers to the schema that holds the CDM data.

* Append the analysis_id number to the destination table so that the achilles function can find it.

* In assigning the analysis_id, try to group the new analysis with other related analyses by referring to the *inst/csv/achilles/achilles_analysis_details.csv* file.


## Export to JSON

* **inst/csv/export/all_reports.csv**: This file defines the standard reports to export when running the exportToJson function.

  + REPORT field
    - The name of the report to export. Any new reports should be added to this column in order to be included as part of the default export. 
    

## Achilles Heel Analyses

* **inst/csv/heel/heel_rules_all.csv**: This file details all of the Heel data quality rules. These rules can be executed either in parallel or in serial.

  + RULE_ID field
    - The identifier for the Heel rule; this is used to identify the SQL files for parallel heel_results and serial results_derived. For serial Heel analyses, the RULE_ID is the ordinal value for serial processing.
    
  + RULE_NAME field
    - The name of the Heel rule
    
  + EXECUTION_TYPE field
    - If the data quality query can be run in parallel, then "parallel." If it is dependent upon the results_derived or heel_results tables existing, then "serial."
    
  + DESTINATION_TABLE field
    - Where will the Heel rule write results to: achilles_heel_results, achilles_results_derived, or both?
    
  + RULE_TYPE field
    - The category of the rule; does it check data quality, some kind of error, or conformance to the CDM schema?
    
  + RULE_DESCRIPTION field
    - The full description of the Heel rule
    
  + THRESHOLD field
    - What is the threshold for the rule to throw an error, warning, or notification?
    
  + RULE_CLASSIFICATION field
    - A category for the rule composition
    
  + RULE_SCOPE field
    - For what population should this rule be applied?
    
  + LINKED_MEASURE field
    - A foreign key to Achilles main or other Heel analyses
    
* **inst/csv/heel/heel_results_derived_details.csv**: This file details the derived results found in the achilles_results_derived table.

  + QUERY_ID field
    - The identifier of each derived Heel analysis; this identifier corresponds to SQL file names.
    
  + MEASURE_ID field
    - The named key of each derived measure
    
  + NAME field
    - The full name of the derived measure
    
  + STATISTIC_VALUE_NAME field
    - The type of statistic (counts, percents, ratios)
    
  + STRATUM_1_NAME, STRATUM_2_NAME fields
    - The values to stratify the measure by
    
  + DESCRIPTION field
    - The full details about the derived measure.
    
  + ASSOCIATED_RULES field
    - A foreign key to the Heel rules defined in the *inst/csv/heel/heel_rules_all.csv* file.

* **inst/csv/heel/heel_rules_drilldown.csv**: This file details the queries for creating drilldown metrics based on higher level Heel results.

  + RULE_ID field
    - The identifier for the Heel rule
    
  + LABEL field
    - A brief description of the drilldown
    
  + DRILL_DOWN_TYPE field
    - The source of the drilldown
    
  + LEVEL field
    - The depth of the drilldown
    
  + DESCRIPTION field
    - A detailed description of the drilldown
    
  + CODE field
    - The SQL query to obtain the drilldown value

### How to Add a Heel Analysis

1. To add a new Heel analysis, first determine whether its results will reside in the achilles_heel_results table, the achilles_results_derived table, or both. 

2. Next, determine if the analysis depends on other analyses. If so, then it should go into the *inst/sql/sql_server/heels/serial* folder. If not, then it should go into the *inst/sql/sql_server/heels/parallel* folder. 
3. Document the Heel analysis in the pertinent CSV files so that they are transparent and reachable by the achillesHeel function. The rule should be added to the *inst/csv/heel/heel_rules_all.csv* file; the rule_id will be important if this analysis needs to run in serial. If the rule includes derived details, add it to the *inst/csv/heel/heel_results_derived_details.csv* file; make sure to tag the rule_id in the ASSOCIATED_RULES field and create a new QUERY_ID to use as the SQL file name. If the rule includes a drilldown metric, include it in the *inst/csv/heel/heel_rules_drilldown.csv* file. 

4. Use the conventions below to write the SQL query. If the Heel analysis needs to run in serial, keep in mind the prerequisites for the new Heel analysis; does it rely upon the achilles_results_derived or achilles_heel_results tables at a specific stage of the achillesHeel execution? 

**Achilles Heel SQL Conventions**

#### Parallel files

Follow the conventions of existing Heel Results queries:  `select <fields> into @scratchDatabaseSchema@schemaDelim@tempHeelPrefix_@heelName from @resultsDatabaseSchema.achilles_analysis`

* The `@scratchDatabaseSchema` parameter refers to the schema that will hold the staging table for this analysis.

* The `@schemaDelim` parameter refers to the delimiter used for this destination staging table (either 's_' or '.'). This is changed based upon whether the user is selecting single threaded or multi-threaded mode.

* The `@tempHeelPrefix` parameter refers to the staging table prefix to use for each staging table ('tmpheel' by default, or whatever the user provides).

* The `@resultsDatabaseSchema` parameter refers to the schema that holds the Achilles tables.

* The `@heelName` parameter is used to uniquely identify the Heel result (and corresponds to the SQL file name).


#### Serial files: achilles_results_derived

Follow the conventions of existing Heel Results queries:  `select <fields> into #serial_rd_@rdNewId from #serial_rd_@rdOldId`

* As these will be run in serial, there is no need to use permanent staging tables. Instead, we use temp staging tables that are then merged into the final permanent achilles_results_derived table. This is to ensure best performance from MPP database platforms.

* The `@rdNewId` parameter refers to the serial file ID of the new achilles_results_derived analysis. The achillesHeel function will assign this based on the rule_id.

* The `@rdOldId` parameter refers to the serial file ID of the previous achilles_results_derived analysis. The achillesHeel function will assign this based on the rule_id.


#### Serial files: achilles_heel_results

Follow the conventions of existing Heel Results queries:  `select <fields> into #serial_hr_@hrNewId from #serial_hr_@hrOldId`

* As these will be run in serial, there is no need to use permanent staging tables. Instead, we use temp staging tables that are then merged into the final permanent achilles_heel_results table. This is to ensure best performance from MPP database platforms.

* The `@hrNewId` parameter refers to the serial file ID of the new achilles_heel_results analysis. The achillesHeel function will assign this based on the rule_id.

* The `@hrOldId` parameter refers to the serial file ID of the previous achilles_heel_results analysis. The achillesHeel function will assign this based on the rule_id.


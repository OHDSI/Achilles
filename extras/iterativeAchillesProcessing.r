
# HOW TO:
#
# Achilles processing can be time consuming and since it functions
# as an all-or-nothing process, end failure (or any single failure) will result in no analyses
# being recorded and the underlying results tables not created.  The example below demonstrates 
# how to run Achilles on smaller-to-larger tables, as an alternative to the default all-or-nothing approach. 
# 

library(Achilles)

analysisDetails <- Achilles::getAnalysisDetails()

# Suppose that you'd like to run Achilles for PERSON, OBSERVATION_PERIOD, VISIT_OCCURRENCE, CONDITION_OCCURRENCE, DRUG_EXPOSURE, and MEASUREMENT
# in that order.  The PERSON table is the smallest in our above list and we'd like to run achilles just for PERSON. If achilles has failed 
# in the past and the achilles results tables were not created, then when running achilles for PERSON, we allow createTable and 
# updateGivenAnalysesOnly to assume their default values (ie, we don't specify them).

personOnly <- analysisDetails[analysisDetails$category == "Person",]$analysis_id

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder          = "Your output folder",
  analysisIds           = personOnly)


# Once the above completes successfully, you can move on to your next smallest table, OBSERVATION_PERIOD.  This time though,
# we need to call Achilles such that the prior PERSON analyses are NOT deleted.  We do so by using createTable = F and
# updateGivenAnalysisOnly = T. 

opOnly <- analysisDetails[analysisDetails$category == "Observation Period",]$analysis_id

Achilles::achilles(
  connectionDetails       = connectionDetails,
  cdmDatabaseSchema       = cdmDatabaseSchema,
  resultsDatabaseSchema   = resultsDatabaseSchema,
  outputFolder            = "Your output folder",
  analysisIds             = opOnly,
  createTable             = F,
  updateGivenAnalysesOnly = T)


# We continue to execute Achilles for VISIT_OCCURRENCE, CONDITION_OCCURRENCE, DRUG_EXPOSURE, and MEASUREMENT 
# as we did for OBSERVATION_PERIOD.  For example, for VISIT_OCCURRENCE:

voOnly <- analysisDetails[analysisDetails$category == "Visit Occurrence",]$analysis_id

Achilles::achilles(
  connectionDetails       = connectionDetails,
  cdmDatabaseSchema       = cdmDatabaseSchema,
  resultsDatabaseSchema   = resultsDatabaseSchema,
  outputFolder            = "Your output folder",
  analysisIds             = voOnly,
  createTable             = F,
  updateGivenAnalysesOnly = T)


# Alternatively, Since personOnly, opOnly, and voOnly, are just vectors analysis_ids, you can loop through these one by one.
# If your achilles_results table does not exist, you need to ensure that achilles is invoked correctly to create that table (see above).
# This is painfully slow, but may be helpful for debugging.  Here's an example.

for (vo_id in voOnly) {
  
  Achilles::achilles(
    connectionDetails       = connectionDetails,
    cdmDatabaseSchema       = cdmDatabaseSchema,
    resultsDatabaseSchema   = resultsDatabaseSchema,
    outputFolder            = "Your output folder",
    analysisIds             = vo_id,
    createTable             = F,
    updateGivenAnalysesOnly = T)
}

# Finally, the column names and data types for achilles_results and achilles_results_dist are found here:
#   https://github.com/OHDSI/Achilles/blob/master/inst/csv/schemas/schema_achilles_results.csv
#   https://github.com/OHDSI/Achilles/blob/master/inst/csv/schemas/schema_achilles_results_dist.csv
# so they can be created manually in SQL as well.

  


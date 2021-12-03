
# Before you run Achilles:achilles() 

Running Achilles::getAnalysisDetails() is a great way to get to know the Achilles package.  See the Q&A below.
```

# Q: What does getAnalysisDetails() do?
# A: getAnalysisDetails() returns a data frame of detailed information regarding all Achilles analyses.
#    We can use getAnalysisDetails() to answer common questions about the different Achilles analyses.

> details <- Achilles::getAnalysisDetails()
> colnames(details)
"ANALYSIS_ID"  "DISTRIBUTION"  "COST"  "DISTRIBUTED_FIELD"  "ANALYSIS_NAME"  "STRATUM_1_NAME" 
"STRATUM_2_NAME"  "STRATUM_3_NAME"  "STRATUM_4_NAME"  "STRATUM_5_NAME"  "IS_DEFAULT" "CATEGORY"         

# Q: How many analyses run by default?
# A: See below.

> length(which(details$IS_DEFAULT == 1))
[1] 292 

# Q: What are the non-default analyses?
# A: See below.

> details[details$IS_DEFAULT == 0,c(1,5)]
ANALYSIS_ID ANALYSIS_NAME
        424 Number of distinct people with co-occurring condition_occurrence condition_concept_id pairs
        624 Number of distinct people with co-occurring procedure_occurrence procedure_concept_id pairs
        724 Number of distinct people with co-occurring drug_exposure drug_concept_id pairs
        824 Number of distinct people with co-occurring observation observation_concept_id pairs
       1824 Number of distinct people with co-occurring measurement measurement_concept_id pairs
	   
# Q: What are the analysis categories?
# A: See below.
	   
> unique(details$CATEGORY)
 [1] "General"      "Person"               "Observation Period"  "Visit Occurrence"   "Provider"  "Condition Occurrence"
 [7] "Death"        "Procedure Occurrence" "Drug Exposure"       "Observation"        "Drug Era"  "Condition Era"       
[13] "Location"     "Care Site"            "Visit Detail"        "Payer Plan Period"  "Cost"      "Cohort"              
[19] "Measurement"  "Completeness"         "Device Exposure"     "Note"                

```

# Running Achilles:achilles()
Use the achilles() function to "run Achilles" against your CDM.  Different ways of executing achilles() are illustrated below.  
```

# Q: How do I run all default analyses? 
# A: See below.  You must supply connectionDetails, cdmDatabaseSchema, and resultsDatabaseSchema.
#    outputFolder will default to pwd/output if not specified.

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder          = "your output folder"
)

# Q: How do I run all analyses? 
# A: Use the defaultAnalysesOnly parameter.  See below. 

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  defaultAnalysesOnly   = FALSE,
  outputFolder          = "your output folder"
)

# Q: How do I run only non-default analyses? 
# A: Use the analysisIds parameter.  See below.  

details     <- Achilles::getAnalysisDetails()
analysisIds <- details[which(details$IS_DEFAULT==0),]$ANALYSIS_ID

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  analysisIds           = analysisIds,
  outputFolder          = "your output folder"
)

# Q: How do I execute only specific analyses, removing old/other analyses if they exist? 
# A: Use the analysisIds parameter.  See below.  

onlyThese <- c(402,702)

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  analysisIds           = onlyThese,
  outputFolder          = "your output folder"
)

# Q: How do I execute (or re-run) certain analyses, without removing previous results for other analyses? 
# A: Use the parameters analysisIds, createTable, and updateGivenAnalysesOnly.  See below.  
# Please see the following forum post for more details: 
# https://forums.ohdsi.org/t/achilles-introducing-new-functionality/14566

reRunThese <- c(402,702)

Achilles::achilles(
  connectionDetails       = connectionDetails,
  cdmDatabaseSchema       = cdmDatabaseSchema,
  resultsDatabaseSchema   = resultsDatabaseSchema,
  analysisIds             = reRunThese,
  updateGivenAnalysesOnly = T,
  createTable             = F,
  outputFolder            = "your output folder"
)

# Q: How do I skip specific analyses? 
# A: Use the excludeAnalysisIds parameter.  See below.  

skipThese <- c(402,702)

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  excludeAnalysisIds    = skipThese,
  outputFolder          = "your output folder"
)

# Q: How do I skip all analyses for a given table? 
# A: Use the excludeAnalysisIds parameter.  See below.  

details   <- Achilles::getAnalysisDetails()
skipThese <- details[details$CATEGORY == "Drug Exposure",]$ANALYSIS_ID

Achilles::achilles(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  excludeAnalysisIds    = skipThese,
  outputFolder          = "your output folder"
)

# Q: How do I find and optionally run analyses that were previously skipped or recently added to Achilles?
# A: Use listMissingAnalyses() to see the analyses and runMissingAnalyses() to run them.
#    NB: runMissingAnalyses() does NOT delete prior data.
# Please see the following forum post for more details: 
# https://forums.ohdsi.org/t/achilles-introducing-new-functionality/14566

Achilles::listMissingAnalyses(connectionDetails,resultsDatabaseSchema)

Achilles::runMissingAnalyses(
  connectionDetails     = connectionDetails,
  cdmDatabaseSchema     = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFolder          = "your output folder"
)

```

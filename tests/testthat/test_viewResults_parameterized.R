#Requires that Achilles has been run first


dbTypes = c("mysql",
            "oracle",
            "postgresql",
            "redshift",
            "sql server",
            "pdw",
            "netezza",
            "bigquery")

for (dbType in dbTypes)
{
  test_that(sprintf("fetchAchillesAnalysisResults does not throw an error on %s", dbType), {
    sysUser <- Sys.getenv(sprintf("CDM5_%s_USER", toupper(dbType)))
    sysPassword <- URLdecode(Sys.getenv(sprintf("CDM5_%s_PASSWORD", toupper(dbType))))
    sysServer <- Sys.getenv(sprintf("CDM5_%s_SERVER", toupper(dbType)))
    sysExtraSettings <- Sys.getenv(sprintf("CDM5_%s_EXTRA_SETTINGS", toupper(dbType)))
    if (sysUser != "" &
        sysPassword != "" &
        sysServer != "") {
      cdmDatabaseSchema <- Sys.getenv(sprintf("CDM5_%s_CDM_SCHEMA", toupper(dbType)))
      resultsDatabaseSchema <- Sys.getenv("CDM5_%s_OHDSI_SCHEMA", toupper(dbType))
      
      details <- createConnectionDetails(dbms = dbType,
                                         user = sysUser,
                                         password = sysPassword,
                                         server = sysServer,
                                         extraSettings = sysExtraSettings)

      fetchAchillesAnalysisResults(connectionDetails = connectionDetails, resultsDatabaseSchema = resultsDatabaseSchema, analysisId = 106)
      
      for (analysisId in analysesDetails$ANALYSIS_ID) {
        results <- fetchAchillesAnalysisResults(connectionDetails, resultsDatabaseSchema, analysisId = analysisId)
      }
    }
  })
}
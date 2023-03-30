generateDomainOverlapSql <- function() {
  # remove existing file as to not endlessly append. :|
  sqlFile <- "domainOverlap.sql"
  if (file.exists(sqlFile)) {
    file.remove(sqlFile)
  }

  # creates a matrix of domain overlap possibilities.  If you want to add a domain, you would add
  # to the list directly below.
  domainMatrix <- tidyr::crossing(condition_occurrence = 0:1,
                                  drug_exposure = 0:1,
                                  device_exposure = 0:1,

    measurement = 0:1, death = 0:1, procedure_occurrence = 0:1, observation = 0:1)
  domainMatrixResults <- domainMatrix
  domainMatrixResults <- domainMatrixResults %>%
    mutate(count = 0, proportion = 0, dataSource = "")


  # Creates notes
  write(x = "-- Analysis 2004: Number of distinct patients that overlap between specific domains",
    sqlFile, append = TRUE)
  write(x = "-- Bit String Breakdown:   1) Condition Occurrence 2) Drug Exposure 3) Device Exposure 4) Measurement 5) Death 6) Procedure Occurrence 7) Observation",
    sqlFile, append = TRUE)
  write(x = "", sqlFile, append = TRUE)

  # Creates temp tables for each specific domain
  write(x = "select distinct person_id into #conoc from @cdmDatabaseSchema.condition_occurrence;", sqlFile, append = TRUE)
  write(x = "select distinct person_id into #drexp from @cdmDatabaseSchema.drug_exposure;", sqlFile, append = TRUE)
  write(x = "select distinct person_id into #dvexp from @cdmDatabaseSchema.device_exposure;", sqlFile, append = TRUE)
  write(x = "select distinct person_id into #msmt from @cdmDatabaseSchema.measurement;", sqlFile, append = TRUE)
  write(x = "select distinct person_id into #death from @cdmDatabaseSchema.death;", sqlFile,append = TRUE)
  write(x = "select distinct person_id into #prococ from @cdmDatabaseSchema.procedure_occurrence;", sqlFile, append = TRUE)
  write(x = "select distinct person_id into #obs from @cdmDatabaseSchema.observation;", sqlFile, append = TRUE)
  write(x = "", sqlFile, append = TRUE)

  write(x = "with rawData as (", sqlFile, append = TRUE)

  # Begins going through domain matrix by row to calculate overlap of different domain
  # combinations.
  for (i in 1:nrow(domainMatrix)) {
    # Builds bit-driven string for strata1
    domainString <- ""
    for (b in 1:ncol(domainMatrix)) {
      domainString <- paste0(domainString, domainMatrixResults[i, b])
    }

    sql <- "select count(*) as count_value from("
    previousDomain <- ""

    # Building of custom domain overlap queries.
    for (j in 1:ncol(domainMatrix)) {
      # Condition Occurrence
      if ((j == 1) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #conoc")
          previousDomain <- "a"
        }
      }

      # Drug Exposure
      if ((j == 2) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #drexp")
          previousDomain <- "b"
        } else {
          sql <- paste0(sql, " intersect select person_id from #drexp")
          previousDomain <- "b"
        }
      }

      # Device exposure
      if ((j == 3) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #dvexp")
          previousDomain <- "c"
        } else {
          sql <- paste0(sql, " intersect select person_id from #dvexp")
          previousDomain <- "c"
        }
      }

      # Measurement
      if ((j == 4) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #msmt")
          previousDomain <- "d"
        } else {
          sql <- paste0(sql, " intersect select person_id from #msmt")
          previousDomain <- "d"
        }
      }

      # Death
      if ((j == 5) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #death")
          previousDomain <- "e"
        } else {
          sql <- paste0(sql, " intersect select person_id from #death")
          previousDomain <- "e"
        }
      }

      # Procedure Occurrence
      if ((j == 6) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #prococ")
          previousDomain <- "f"
        } else {
          sql <- paste0(sql, " intersect select person_id from #prococ")
          previousDomain <- "f"
        }
      }

      # Observation
      if ((j == 7) & (domainMatrix[i, j] == 1)) {
        if (sql == "select count(*) as count_value from(") {
          sql <- paste0(sql, "select person_id from #obs")
        } else {
          sql <- paste0(sql, " intersect select person_id from #obs")
        }
      }

    }  # End for loop for domainMatrix by column

    sql <- paste0(sql, ")")

    # Formats output for achilles_results input
    preSql <- paste0("select 2004 as analysis_id,
       '", domainString, "' as stratum_1,
       cast((1.0 * personIntersection.count_value / totalPersonsDb.totalPersons) as varchar(255)) as stratum_2,
       CAST(NULL AS VARCHAR(255)) as stratum_3,
       CAST(NULL AS VARCHAR(255)) as stratum_4,
       CAST(NULL AS VARCHAR(255)) as stratum_5,
       personIntersection.count_value
      from
      (")

    # Creates Unions for generation of .sql file
    if (i == nrow(domainMatrix)) {
      postSql <- " as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb) select * INTO @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2004 from rawData;"
    } else {
      postSql <- " as subquery) as personIntersection,
  (select count(distinct(person_id)) as totalPersons from @cdmDatabaseSchema.person) as totalPersonsDb UNION ALL"
    }


    sql <- paste0(preSql, sql, postSql)

    # ignores creation no domain specified
    if (domainString == "0000000") {
      next
    } else {
      write(x = sql, sqlFile, append = TRUE)
    }

  }  # End for loop for domainMatrix by row
  
  
  # clean up temp tables
  # Creates temp tables for each specific domain
  write(x = "drop table #conoc;", sqlFile, append = TRUE)
  write(x = "drop table #drexp;", sqlFile, append = TRUE)
  write(x = "drop table #dvexp;", sqlFile, append = TRUE)
  write(x = "drop table #msmt;", sqlFile, append = TRUE)
  write(x = "drop table #death;", sqlFile, append = TRUE)
  write(x = "drop table #prococ;", sqlFile, append = TRUE)
  write(x = "drop table #obs;", sqlFile, append = TRUE)
  write(x = "", sqlFile, append = TRUE)  
}  # End function

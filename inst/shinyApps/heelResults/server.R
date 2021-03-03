library(shiny)
library(DT)
library(magrittr)
library(tidyr)

shinyServer(function(input, output, session) {

  Heels <- reactive({
    df <- readRDS(file.path(Sys.getenv("outputFolder"), "heelResults.rds"))
    df <- separate(data = df,
                   col = ACHILLES_HEEL_WARNING,
                   into = c("WARNING_TYPE", "ACHILLES_HEEL_WARNING"),
                   sep = ":",
                   extra = "merge")

    df <- dplyr::arrange(df, ANALYSIS_ID) %>% dplyr::select(`Analysis Id` = ANALYSIS_ID,
                                                            `Rule Id` = RULE_ID,
                                                            `Warning Type` = WARNING_TYPE,
                                                            Message = ACHILLES_HEEL_WARNING,
                                                            `Record Count` = RECORD_COUNT)
    df
  })

  output$heelTable <- renderDataTable({

    df <- Heels()

    options <- list(pageLength = 10000,
                    searching = TRUE,
                    lengthChange = FALSE,
                    ordering = TRUE,
                    paging = FALSE,
                    scrollY = "75vh")
    selection <- list(mode = "single", target = "row")

    table <- datatable(df,
                       options = options,
                       selection = "single",
                       rownames = FALSE,
                       class = "stripe nowrap compact") %>%
      formatStyle("Warning Type",
                  target = "row",
                  backgroundColor = styleEqual(c("NOTIFICATION", "WARNING", "ERROR"),
                                               c("#e8f0ff", "#fffedb", "#ffdbdb")))

    return(table)
  })

  output$analysisInfo <- renderText({
    if (length(input$heelTable_rows_selected) == 0) {
      return("No Heel warning selected")
    }

    row_count <- input$heelTable_rows_selected
    analysisId <- Heels()[row_count, ]$`Analysis Id`

    if (!is.na(analysisId)) {

      sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sprintf("analyses/%s.sql", analysisId),
                                               packageName = "Achilles",
                                               dbms = Sys.getenv("dbms"),
                                               warnOnMissingParameters = FALSE,
                                               cdmDatabaseSchema = Sys.getenv("cdmDatabaseSchema"),
                                               resultsDatabaseSchema = Sys.getenv("resultsDatabaseSchema"),
                                               scratchDatabaseSchema = Sys.getenv("scratchDatabaseSchema"),
                                               schemaDelim = Sys.getenv("schemaDelim"),
                                               tempAchillesPrefix = Sys.getenv("tempAchillesPrefix"))

      return(sql)
    }

    return("NA")
  })

  output$ruleInfo <- renderText({
    if (length(input$heelTable_rows_selected) == 0) {
      return("No Heel warning selected")
    }

    row_count <- input$heelTable_rows_selected
    ruleId <- Heels()[row_count, ]$`Rule Id`

    if (!is.na(ruleId)) {

      row <- ruleDetails[ruleDetails$rule_id == ruleId, ]

      if (row$execution_type == "parallel") {
        if (row$destination_table == "heel_results") {
          sqlFile <- sprintf("heels/parallel/heel_results/rule_%d.sql", ruleId)
        } else {
          sqlFile <- sprintf("heels/parallel/results_derived/%d.sql", ruleId)
        }
      } else {
        sqlFile <- sprintf("heels/serial/rule_%d.sql", ruleId)
      }

      sql <- SqlRender::loadRenderTranslateSql(sqlFilename = sqlFile,
                                               packageName = "Achilles",
                                               dbms = Sys.getenv("dbms"),
                                               warnOnMissingParameters = FALSE,
                                               cdmDatabaseSchema = Sys.getenv("cdmDatabaseSchema"),
                                               resultsDatabaseSchema = Sys.getenv("resultsDatabaseSchema"),
                                               scratchDatabaseSchema = Sys.getenv("scratchDatabaseSchema"),
                                               schemaDelim = Sys.getenv("schemaDelim"),
                                               tempHeelPrefix = Sys.getenv("tempHeelPrefix"),
                                               heelName = ruleId)
      return(sql)
    }

    return("NA")
  })

  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(filename = function() {
    "heelResults.csv"
  }, content = function(file) {
    write.csv(Heels(), file, row.names = FALSE)
  })
})

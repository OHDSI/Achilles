library(shiny)
library(DT)
library(magrittr)
library(tidyr)

shinyServer(function(input, output, session) {
  

  output$cohortTable <- renderDataTable({
    
    df <- readRDS(file.path(Sys.getenv("outputFolder"), "heelResults.rds"))
    df <- separate(data = df, col = ACHILLES_HEEL_WARNING, into = c("WARNING_TYPE", "ACHILLES_HEEL_WARNING"), sep = ":", extra = "merge")
    
    df <- dplyr::arrange(df, ANALYSIS_ID) %>%
          dplyr::select(`Analysis Id` = ANALYSIS_ID,
                        `Warning Type` = WARNING_TYPE,
                        `Message` = ACHILLES_HEEL_WARNING,
                        `Rule Id` = RULE_ID,
                        `Record Count` = RECORD_COUNT)
    
    options = list(pageLength = 10000, 
                   searching = TRUE, 
                   lengthChange = FALSE,
                   ordering = TRUE,
                   paging = FALSE,
                   scrollY = '75vh')
    selection = list(mode = "single", target = "row") 
    
    table <- datatable(df, 
                       options = options, 
                       selection = "single",
                       rownames = FALSE,
                       class = "stripe nowrap compact") %>% 
      formatStyle("Warning Type",
                  target = "row", 
                  backgroundColor = styleEqual(c("NOTIFICATION", "WARNING", "ERROR"), c("#e8f0ff", "#fffedb", "#ffdbdb")))
    
    return (table)
  })
})
library(shiny)
library(DT)

shinyUI(
  fluidPage(
    titlePanel(title = div(img(src = "ohdsi_logo.png"), strong(sprintf("Achilles Heel Results Viewer: %s", Sys.getenv("sourceName")))), 
               windowTitle = "Achilles Heel Results Viewer"),
    fluidRow(
      column(9, 
             dataTableOutput("heelTable")),
      column(3, 
             downloadButton("downloadData", "Download Heel Results"),
             shiny::HTML("<h3>Associated Analysis SQL</h3>"), 
             verbatimTextOutput("analysisInfo", placeholder = TRUE),
             shiny::HTML("<h3>Associated Heel SQL</h3>"),
             verbatimTextOutput("ruleInfo", placeholder = TRUE))
    )
  )
)
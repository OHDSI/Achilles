library(shiny)
library(DT)

shinyUI(
  fluidPage(
    titlePanel(title = div(img(src = "ohdsi_logo.png"), strong(sprintf("Achilles Heel Results Viewer: %s", Sys.getenv("sourceName")))), 
               windowTitle = "Achilles Heel Results Viewer"),
    fluidRow(
      column(10,
             dataTableOutput("cohortTable"))
    )
  )
)
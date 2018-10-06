library(shiny)
library(DT)

shinyUI(
  fluidPage(
    titlePanel(title = div(img(src = "ohdsi_logo.png"), strong("Achilles Heel Results Viewer")), windowTitle = "Achilles Heel Results Viewer"),
    fluidRow(
      column(10,
             dataTableOutput("cohortTable"))
    )
  )
)
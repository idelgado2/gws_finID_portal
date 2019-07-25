### This is the UI file for our groundUP file ###

library(shiny)
library(rsconnect)

shinyUI(
  navbarPage(
    id = "form",
    title = "FinID Data Entry",
    tabPanel("Survey Info",
              sidebarPanel(),
              mainPanel()
    ),
    tabPanel("Fin Photo Entry",
              sidebarPanel(),
              mainPanel()
    ),
    tabPanel("Data Submission",
              sidebarPanel(),
              mainPanel()
    ),
  )
)

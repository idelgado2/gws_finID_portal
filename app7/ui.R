### This is the UI file for our groundUP file ###

library(shiny)
library(rsconnect)
source("fin_shiny_fxns2.R")

shinyUI(
  navbarPage(
    id = "form",
    title = "FinID Data Entry",
    ###############
    ##SURVEY INFO##
    ###############
    tabPanel("Survey Info",
              sidebarPanel(
                selectInput(
                  "site.phid",
                  labelMandatory("Survey site"),
                  choices = flds$sites
                ),
                dateInput(
                  "date.phid",
                  labelMandatory("Survey date"),
                  value = Sys.Date(),
                  format = "yyyy-mm-dd"
                ),
                hr(),
                checkboxGroupInput(
                  "crew",
                  "Crew",
                  choices = flds$observers,
                  inline = T
                ),
                textInput(
                  "vessel",
                  "Vessel",
                  placeholder = "MBA Skiff? Norcal? R/V BS?"
                )
              ),
              mainPanel(
                sliderInput(
                  "effort",
                  "Start/Stop of Survey Effort?",
                  min = 6,
                  max = 20,
                  value = c(8, 15)
                ),
                textInput(
                  "notes.survey",
                  "Notes from survey day",
                  placeholder = "breaches? predations?",
                  width = "100%"
                ),
                textOutput("crew"),
                actionButton(
                  "addfins",
                  "Ready to add Fins?",
                  class="btn-primary"
                )
              )
    ),
    ################
    ##FIN ID ENTRY##
    ################
    tabPanel("Fin Photo Entry",
              sidebarPanel(),
              mainPanel()
    ),
    ###################
    ##DATA SUBMISSION##
    ###################
    tabPanel("Data Submission",
              sidebarPanel(),
              mainPanel()
    )
  )
)

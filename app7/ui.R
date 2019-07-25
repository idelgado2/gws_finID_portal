### This is the UI file for our groundUP file ###

library(shiny)
library(rsconnect)
source("fin_shiny_fxns2.R")

appCSS <- ".mandatory_star { color: red; }" #Red Star CSS for required inputs

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
                ),
                #### TESTING HTML HERE ####
                textOutput("site.phid"),
                textOutput("date.phid")
              )
    ),
    ################
    ##FIN ID ENTRY##
    ################
    tabPanel("Fin Photo Entry",
              inlineCSS(appCSS),
              sidebarPanel(
                radioButtons("user", "User", choices = flds$observers, inline = T, selected=character(0)),
                numericInput("sighting.phid", labelMandatory("Sighting #"), value = NULL, min = 01, max = 99, step =1),
                hr(),
                fileInput("fin.photo", labelMandatory("Upload fin here"), multiple = F, 
                            accept=c("image/jpeg", "image/png", "image/tiff",".jpeg", ".jpg", ".png", ".tiff")),
                textInput("time", labelMandatory("Time of Observation"), placeholder = "24HR CLOCK PLS (e.g., 0915 for 9:15)"),
                hr(),
                selectInput("sex", labelMandatory("Sex (U if unknown)"), choices = c("M", "F", "U"), selectize = F, selected = "U"), 
                numericInput("size", labelMandatory("Size (in ft)"), value = NULL, min = 4, max = 20, step = 0.5),
                hr()
                #conditionalPanel()
              ),
              mainPanel(
                useShinyjs()
                #uiOutput("site.phid"),
                #uiOutput("date.phid")
              )
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

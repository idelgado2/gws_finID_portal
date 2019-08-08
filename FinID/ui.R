### This is the UI file for our groundUP file ###

library(shiny)
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
                hr(),
                conditionalPanel(
                  condition = "output.finuploaded",
                  textInput("notes", "Notes", placeholder = "e.g. pings heard, secondary marks, scars, nicknames, etc", width = "600px"),
                  selectInput("tag.exists", "Tagged Already?", choices = c("U", "Y"), selected = "U"),
                  selectInput("tagdeployed", "New Tag?", choices = c("None", "PAT", "Acoustic", "Stomach", "Clamp"), selected = "None"),
                  radioButtons("tag.side", "Deployed On? ", choices = c("NA", "L", "R"), inline = T),
                  textInput("tag.id", "Tag ID#"),
                  textInput("tag.notes", "Tagging Notes", width = '600px', placeholder = "e.g., programming params, Ptt/SPOT used, orientation"),
                  selectInput("biopsy", "Biopsy?", choices = c("N", "Y"), selected="N"),
                  textInput("biopsy.id", "Vial Number?")
                )
              ),
              mainPanel(
                useShinyjs(),
                uiOutput("siteOutput.phid"),
                uiOutput("dateOutput.phid"),
                textOutput("path"),
                uiOutput("PhotoID"),
                hr(),
                conditionalPanel("output.finuploaded",
                                 textInput("match.sugg", "Suggestions to the MatchMaker?", placeholder = "Zat you, Burnsey?", width = "600px"),
                                 imageOutput(outputId = "FinShot", width = "auto", height="auto"),
                                 hr(),
                                 uiOutput("xyloc"),
                                 textInput("lat", labelMandatory("Latitude"), placeholder = "36.618149"),
                                 textInput("long", labelMandatory("Longitude"), placeholder = "-121.901939"),
                                 leafletOutput("map"),
                                 DT::dataTableOutput("dataentry"),
                                 conditionalPanel("mandatoryFilled",
                                                  actionButton("masfins", "Mas Fins?", class="btn-primary"),
                                                  actionButton("r2submit", "Ready To Submit?", class="btn-primary")
                                 )
                                )
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

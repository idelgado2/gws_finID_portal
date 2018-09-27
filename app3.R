#dev following mtg w/ sal, paul, scot
#multi panel for survey info & 
#9/25/18
#adapting basic app to shinyforms fork
source("fin_shiny_fxns2.R")

responseDir <- file.path("entries")
fileName = "here_lies_data.csv"
shinyApp(ui = navbarPage(
  title = "FinID Data Entry",
  
  ###############
  ##SURVEY INFO##
  ###############
  tabPanel("Survey Info",
           sidebarPanel(
             #Survey inputs
             id = "form", 
             checkboxGroupInput("crew", "Crew", 
                                choices = flds$observers, inline = T),
             selectInput("survey", "Monitoring Loc",
                         choices = flds$sites),
             textInput("vessel", "Vessel platform", placeholder = "Kingfisher? BS?"),
             ###MAKE THIS THE X/Y BIT
             dateInput("date.survey", "Date", 
                       value = Sys.Date(), format = "yyyy-mm-dd")
             ),
           mainPanel(
             #outputs for tab 1
             sliderInput("effort.on", "On Effort?", 
                       value = 8, min = 4, max = 20, step = 0.5),
             sliderInput("effort.off", "Off Effort?",
                       value = 15, min = 4, max = 20, step = 0.5),
             textInput("notes.survey", "Notes from survey day", 
                       placeholder = "breaches? predations?", width = "100%"), 
             
             textOutput("effort.on")
           )
  ),
  
  ################
  ##FIN ID ENTRY##
  ################
  tabPanel("Fin Photo Entry",
           sidebarPanel(
             #file upload
             radioButtons("observer", "Observer", 
                                choices = flds$observers, inline = T),
             fileInput("fin.photo", "Upload fin here", 
                       multiple = F, accept=c("image/jpeg", "image/png", "image/tiff",
                                              ".jpeg", ".jpg", ".png", ".tiff")),
             #PhotoID fields
             #lapply(entries, FUN = qMaker), #deprecated cannot mimic shinyforms yet
             hr(),
             selectInput("site.phid", "Monitoring Site", choices = c("PR", "FAR", "AN", "APT")),
             dateInput("date.phid", "Date", value = Sys.Date(), format = "yyyy-mm-dd"),
             numericInput("sighting.phid", "Sighting #", value = NULL, min = 01, max = 99, step =), #MAKE THIS NUMERIC?
             
             hr(), #break in UI
             selectInput("sex", "Sex (U if unknown)", choices = c("M", "F", "U"), 
                         selectize = F, selected = "U"), 
             sliderInput("size", "Size (in ft)", value = 13.0, min = 4, max = 20, step = 0.5),
             textInput("notes", "Notes", placeholder = "e.g. pings heard, secondary marks, scars, nicknames, etc", 
                       width = "600px"),
             selectInput("tag.exists", "Tagged Already?", choices = c("U", "Y"), selected = "U"),
             selectInput("tagdeployed", "New Tag?", choices = c("None", "PAT", "Acoustic", "Stomach", "Clamp"), selected = "None"),
             #make ^ check box and conditional panel for each tag selected?
             conditionalPanel(
               condition = "input.tagdeployed != 'None'",
               radioButtons("tag.side", "Deployed On? ", choices = c("L", "R"), 
                                  inline = T), 
               textInput("tag.id", "Tag ID#"),
               textInput("tag.notes", "Tagging Notes", width = '600px', 
                         placeholder = "e.g., programming params, Ptt/SPOT used, orientation"),
               selectInput("biopsy", "Biopsy?", choices = c("N", "Y"), selected="N"),
               conditionalPanel(
                 condition = "input.biospy != 'N'",
                 textInput("biopsyID", "Vial Number?")
               )
             )
             
             
           ), 
           mainPanel(
             textOutput("PhotoID"),
             imageOutput(outputId = "FinShot"),
             hr(),
             textInput("match.sugg", "Suggestions to the MatchMaker?", placeholder = "Zat you, Burnsey?", 
                       width = "600px"),
             textInput("time", "Time of Sighting", placeholder = "24hr CLOCK PLS (e.g., 0915 for 9:15")
           )
  ),
  tabPanel("Data Submission",
           fluidPage(
             #display data
             DT::dataTableOutput("responsesTable"),
             checkboxInput("reviewed", 
                           label = "I have reviewed this data and certify my wish to submit it", 
                           value = F)
           )
  )
),
server = function(input, output, session) {
  #Page 1 server stuff
  output$site.survey <- renderText({input$survey})
  output$date.survey <- renderText({format(input$date.survey, "%Y-%m-%d")}) 
  output$effort.on <- renderText({sprintf("%04s", input$effort.on*100)})
  
  
  ######################
  ######################
  #Page 2 server stuff
  #Make Fin & PhotoID appear
  re1 <- reactive({gsub("\\\\","/", input$fin.photo$datapath)})
  output$FinShot <- renderImage({list(src = re1())})
  output$PhotoID <- renderText({paste0(toupper(input$site.phid),
                                       format(input$date.phid, "%y%m%d"),
                                       sprintf("%02s", input$sighting.phid))})
  
  output$date.phid <- renderText({input$date.phid})
  
  
  #build data frame
  output$responsesTable <- DT::renderDataTable(
    loadData(),
    rownames = FALSE,
    options = list(searching = FALSE, lengthChange = FALSE)
  )
}
)
  
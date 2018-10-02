#Data Entry for GWS Monitoring CentralCA
#uses multiple panels for survey info, Photo entry, Data Submission
#JHMoxley, 9/25/18
#
source("fin_shiny_fxns2.R")
#set up dropbox
token <- readRDS("droptoken.rds")
drop_acc(dtoken=token)
#set up acct
#Sys.setlocale(locale="en_US.UTF-8")


# dd <- file.path("entries")
# fN = "here_lies_data.csv"
shinyApp(ui = navbarPage(
  id = "form",
  title = "FinID Data Entry",
  
  ###############
  ##SURVEY INFO##
  ###############
  tabPanel("Survey Info",
           sidebarPanel(
             #Survey inputs
             checkboxGroupInput("crew", "Crew", 
                                choices = flds$observers, inline = T),
             textInput("vessel", "Vessel platform", placeholder = "Kingfisher Skiff? Norcal? R/V BS?"),
             hr(),
             selectInput("survey", "Survey Location",
                         choices = flds$sites),
             dateInput("date.survey", "Date", 
                       value = Sys.Date(), format = "yyyy-mm-dd")
             ###MAKE THIS THE X/Y BIT
             ###sal wants xy bit in the fin ID
             
             ),
           mainPanel(
             #outputs for tab 1
             sliderInput("effort.on", "On Effort?", 
                       value = 8, min = 4, max = 20, step = 0.5),
             sliderInput("effort.off", "Off Effort?",
                       value = 15, min = 4, max = 20, step = 0.5),
             textInput("notes.survey", "Notes from survey day", 
                       placeholder = "breaches? predations?", width = "100%"),
             textOutput("crew")
             
           )
  ),
  
  ################
  ##FIN ID ENTRY##
  ################
  tabPanel("Fin Photo Entry",
           sidebarPanel(
             #file upload
             radioButtons("user", "User", 
                                choices = flds$observers, inline = T),
             #PhotoID fields first
             selectInput("site.phid", "Monitoring Site", selected = uiOutput("site.survey"),
                         choices = flds$sites),
             dateInput("date.phid", "Date", value = NULL, format = "yyyy-mm-dd"),
             numericInput("sighting.phid", "Sighting #", value = NULL, 
                          min = 01, max = 99, step =1), #MAKE THIS NUMERIC?
             hr(),
             fileInput("fin.photo", "Upload fin here", 
                       multiple = F, accept=c("image/jpeg", "image/png", "image/tiff",
                                              ".jpeg", ".jpg", ".png", ".tiff")),
             hr(), #break in UI
             conditionalPanel(   #collect data once fin is uploaded & photoID is crorect       
                 condition = "output.finuploaded",
                 selectInput("sex", "Sex (U if unknown)", choices = c("M", "F", "U"), 
                             selectize = F, selected = "U"), 
                 numericInput("size", "Size (in ft)", value = NULL, min = 4, max = 20, step = 0.5),
                 textInput("notes", "Notes", placeholder = "e.g. pings heard, secondary marks, scars, nicknames, etc", 
                           width = "600px"),
                 selectInput("tag.exists", "Tagged Already?", choices = c("U", "Y"), selected = "U"),
                 selectInput("tagdeployed", "New Tag?", choices = c("None", "PAT", "Acoustic", "Stomach", "Clamp"), selected = "None"),
                 #make ^ check box and conditional panel for each tag selected?
                 conditionalPanel(
                   condition = "input.tagdeployed != 'None'",
                   radioButtons("tag.side", "Deployed On? ", choices = c("NA", "L", "R"), 
                                      inline = T), 
                   textInput("tag.id", "Tag ID#"),
                   textInput("tag.notes", "Tagging Notes", width = '600px', 
                             placeholder = "e.g., programming params, Ptt/SPOT used, orientation"),
                   selectInput("biopsy", "Biopsy?", choices = c("N", "Y"), selected="N"),
                   conditionalPanel(
                     condition = "input.biospy != 'N'",
                     textInput("biopsy.id", "Vial Number?")
                   )
                 )
             )
             
             
           ), 
           mainPanel(useShinyjs(),
             textOutput("PhotoID"),
             imageOutput(outputId = "FinShot", width = "auto", height="auto"),
             hr(),
             textInput("match.sugg", "Suggestions to the MatchMaker?", placeholder = "Zat you, Burnsey?", 
                       width = "600px"),
             textInput("time", "Time of Observation", placeholder = "24HR CLOCK PLS (e.g., 0915 for 9:15"),
             hr(),
             conditionalPanel("output.finuploaded",
               DT::dataTableOutput("dataentry"),
               actionButton("masfins", "Mas Fins?", class="btn-primary"),
               actionButton("r2submit", "Ready To Submit?", class="btn-primary")
               #submit button that tabs to next panel?
             )
           )
  ),
  ################
  ##DATA SUBMISSION##
  ################
  tabPanel("Data Submission",
           fluidPage(
             checkboxInput("reviewed", 
                           label = "I HAVE VERIFIED THE DATA", 
                           value = F),
             #display data
             DT::dataTableOutput("finsTable"),
             
             #reveal button if data is reviewed
             uiOutput("reviewed")
        )
  )
),
################
##SERVER##
################
server = function(input, output, session) {
  #enlarge maximum upload size 
  options(shiny.maxRequestSize=30*1024^2)
  
  ######################
  ######################
  ##Page 1 server stuff
  #update phids from survey
  observeEvent(input$survey,{
    updateSelectInput(session, "site.phid", selected = input$survey)
  }) 
  observeEvent(input$date.survey,{
    updateDateInput(session, "date.phid", value = input$date.survey)
  })
  
  ######################
  ######################
  ##Page 2 server stuff
  #data gatekeeper, fields can be entered once PhotoID & file exists
  finUP <- reactive({
    if(is.null(input$fin.photo)){
      return(NULL)
    }else{
      #make fin photo
      re1 <- reactive({gsub("\\\\","/", input$fin.photo$datapath)})
      output$FinShot <- renderImage({list(src = re1())})
      #make id
      output$PhotoID <- renderText({paste0(toupper(input$site.phid),
                                           format(input$date.phid, "%y%m%d"),
                                           ifelse(nchar(input$sighting.phid==1), 
                                                  paste0("0", input$sighting.phid),
                                                  input$sighting.phid))})
    }
  })
  output$finuploaded <- reactive({
    #hide the data entry tbl until essential info is included
    return(!is.null(finUP()) && !is.na(input$sighting.phid))
  })
  outputOptions(output, 'finuploaded', suspendWhenHidden=F)
  
  output$dataentry <- DT::renderDataTable(
      formData(),
      rownames = FALSE,
      options = list(searching = FALSE, lengthChange = FALSE,
                columnDefs=list(
                  list(visible = F, targets = c(14:17))))
  )
  
  
  ######################
  ######################
  ##Page 3 server stuff
  #build data frame, needs to become reactive
  #output$reviewed <- renderText({input$reviewed})
  output$reviewed <- renderUI({
    if(input$reviewed == T){
      actionButton("SAVEDATA", "SUBMIT & STORE", class="btn-primary")}
  })
  
  # review <- reactive({
  #   if(output$reviewed==F){return(NULL)}
  #   else{
  #     output$reviewCHK <- renderText({input$reviewed})
  #   }
  # })
  # output$reviewed <- return(review())

  ######################
  ######################
  ##Data making stuff
  formData <- reactive({
    #save photo
    if(is.null(finUP)){
      return(NULL)
      ##SOME WARNING DAATA WILL NOT BE SAVED W?O A PHOTO FILE
      }
    else{
    
      
    #can make the fields match zegami here? 
    data <- c(refID = "UNMATCHED", name = "NONE_YET", 
              match.sugg = as.character(input$match.sugg), 
              time.obs = as.character(input$time),
              # PhotoID = paste0(toupper(input$site.phid), 
              #                  format(input$date.phid, "%y%m%d"), 
              #                  sprintf("%02s", input$sighting.phid)), 
              PhotoID = paste0(toupper(input$site.phid), 
                               format(input$date.phid, "%y%m%d"), 
                               ifelse(nchar(input$sighting.phid==1), 
                                      paste0("0", input$sighting.phid),
                                      input$sighting.phid)), 
              site = toupper(as.character(input$site.phid)), 
              date = as.character(input$date.phid), 
              sighting = as.character(input$sighting.phid),
              sex = as.character(input$sex),
              size = as.character(round(input$size/0.5)*0.5),
              tag.exists = as.character(input$tag.exists),
              tag.deployed = as.character(input$tagdeployed),
              tag.id = as.character(input$tag.id),
              tag.side = as.character(input$tag.side),
              biopsy = as.character(input$biopsy),
              biopsy.id = as.character(input$biopsy.id),
              notes = as.character(input$notes),
              tagging.notes = as.character(input$tag.notes),
              user = as.character(input$user),
              timestamp = epochTime(), 
              #one row, one entry, one photo
              fN = paste0("CCA_GWS_PHID_", 
                          #photoID
                           toupper(input$site.phid),
                           format(input$date.phid, "%y%m%d"), 
                           ifelse(nchar(input$sighting.phid==1), 
                                 paste0("0", input$sighting.phid),
                                 input$sighting.phid), "_",
                          #timestamp
                           as.integer(Sys.time()),
                           ".csv"),
              survey.crew = as.character(paste(input$crew, collapse = "|")),
              survey.effortON = as.character(input$effort.on),
              survey.effortOFF = as.character(input$effort.off),
              survey.notes = as.character(input$survey.notes)
    )
    data <- t(data)
    data
    }
  })
  
  
  savePhoto <- reactive({
    #save photo
    if(is.null(finUP)){
      return(NULL)
      ##SOME WARNING DAATA WILL NOT BE SAVED W?O A PHOTO FILE
    }
    else{
     #somehow save photo in here??   
    }
  })
  
  ######################
  ######################
  ##Button doing stuff
  
  #Observe "mas fins" event here
  #make the pathways
  
  #WHERE TO PUT IT TO DIFF FROM SUBMIT BUTTON? 
  observeEvent(input$masfins, {
    data <- data.frame(formData(), stringsAsFactors = F)
    #savePhoto2(input$fin.photo, data$PhotoID)
    saveData2(data)
    #update pg 3 
    # output$finsTable <- DT::renderDataTable(
    #   loadData(dd),
    #   rownames = FALSE,
    #   options = list(searching = FALSE, lengthChange = FALSE)
    # )
    output$finsTable <- DT::renderDataTable(
      loadData2(data$fN),
      rownames = F, options = list(searching=F, lengthChange=F)
      )
    
    #reset fields
    sapply(c("sighting", "sex", "size", "tag.exists", "tagdeployed", "tag.id",
             "tag.side", "biopsy", "biopsy.id", "notes", "tag.notes",
             "fin.photo", "PhotoID", "finuploaded", "match.sugg", "time", "FinShot"), 
           reset)
    reset("data")
    
  })
  
  
  ##Somehow do something different 
  observeEvent(input$r2submit, {
    #click masfins to save photo/data
    observe({
      shinyjs::click("masfins")})
    #move user to submission page
    updateTabsetPanel(session, "form", selected = "Data Submission")
  })
  
  ##actions once data can be stored
  observeEvent(input$SAVEDATA,{

  })
  
}
)
#shinyApp(ui, server)
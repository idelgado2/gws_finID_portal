#Data Entry for GWS Monitoring CentralCA
#New gen, attempt to implement:
#update msg's, less buggy buttons, naming conflicts, & x/y leaflet
#JHMoxley, 9/25/18

source("fin_shiny_fxns2.R")
#set up dropbox
token <- readRDS("droptoken.rds")
drop_acc(dtoken=token)
appCSS <- ".mandatory_star { color: red; }"
#database for survey entries
dB <- data.frame(NULL)

####
#APP
shinyApp(ui = navbarPage(
  id = "form",
  title = "FinID Data Entry",
  
  ###############
  ##SURVEY INFO##
  ###############
  tabPanel("Survey Info",
           sidebarPanel(
             #Survey inputs
             #file upload
             selectInput("site.phid", labelMandatory("Survey site"),
                         choices = flds$sites),
             dateInput("date.phid", labelMandatory("Survey date"), 
                       value = Sys.Date(), format = "yyyy-mm-dd"),
             hr(),
             checkboxGroupInput("crew", "Crew", 
                                choices = flds$observers, inline = T),
             textInput("vessel", "Vessel", placeholder = "MBA Skiff? Norcal? R/V BS?")
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
           shinyjs::inlineCSS(appCSS),
           sidebarPanel(
             
             #PhotoID fields first
             #selectInput("site.phid", labelMandatory("Monitoring Site"), selected = uiOutput("site.survey"),
             #            choices = flds$sites),
             #dateInput("date.phid", labelMandatory("Date"), value = NULL, format = "yyyy-mm-dd"),
             radioButtons("user", "User", 
                          choices = flds$observers, inline = T, selected=character(0)),
             # uiOutput("site.phid"),
             # uiOutput("date.phid"),
             numericInput("sighting.phid", labelMandatory("Sighting #"), value = NULL, 
                          min = 01, max = 99, step =1), #MAKE THIS NUMERIC?
             hr(),
             fileInput("fin.photo", labelMandatory("Upload fin here"), 
                       multiple = F, accept=c("image/jpeg", "image/png", "image/tiff",
                                              ".jpeg", ".jpg", ".png", ".tiff")),
             textInput("time", labelMandatory("Time of Observation"), placeholder = "24HR CLOCK PLS (e.g., 0915 for 9:15"),
             hr(),
             selectInput("sex", labelMandatory("Sex (U if unknown)"), choices = c("M", "F", "U"), 
                         selectize = F, selected = "U"), 
             numericInput("size", labelMandatory("Size (in ft)"), value = NULL, min = 4, max = 20, step = 0.5),
             hr(), #break in UI
             conditionalPanel(   #collect data once fin is uploaded & photoID is crorect       
               condition = "output.finuploaded",
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
                     uiOutput("site.phid"),
                     uiOutput("date.phid"),
                     uiOutput("PhotoID"),
                     hr(),
                     conditionalPanel("output.finuploaded",
                                      textInput("match.sugg", "Suggestions to the MatchMaker?", placeholder = "Zat you, Burnsey?", 
                                                width = "600px"),
                                      imageOutput(outputId = "FinShot", width = "auto", height="auto"),
                                      DT::dataTableOutput("dataentry"),
                                      conditionalPanel("mandatoryFilled",
                                                       actionButton("masfins", "Mas Fins?", class="btn-primary"),
                                                       actionButton("r2submit", "Ready To Submit?", class="btn-primary")
                                      )#submit button that tabs to next panel?
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
  # observeEvent(input$survey,{
  #   updateSelectInput(session, "site.phid", selected = input$survey)
  # }) 
  # observeEvent(input$date.survey,{
  #   updateDateInput(session, "date.phid", value = input$date.survey)
  # })
  output$site.phid = renderText({paste("<font color=\"#FF0000\"><b>SURVEY SITE<font color=\"#000000\"></b> assigned as: ", 
                                       HTML(paste0("<font color=\"#FF0000\"><b>", input$site.phid, "<b>")))})
  output$date.phid = renderText({paste(HTML("<font color=\"#FF0000\"><b>SURVEY DATE<font color=\"#000000\"></b> assigned as: "), 
                                       HTML(paste0("<font color=\"#FF0000\"><b>",
                                                   as.Date(input$date.phid, format = "%m-%d-%Y"),
                                                   "</b>")))})
  
  ######################
  ######################
  ##Page 2 server stuff
  
  #data gatekeeper, fields can be entered once PhotoID & file exists
  phid <- reactiveValues()
  finUP <- reactive({
    if(is.null(input$fin.photo)){
      return(NULL)
    }else{
      #make fin photo
      cat("the datapath currently is", file.exists(input$fin.photo$datapath), "\n")
      re1 <- reactive({gsub("\\\\","/", input$fin.photo$datapath)})
      output$FinShot <- renderImage({list(src = re1())}, deleteFile = FALSE)
      #make id
      phid$val <- paste0(toupper(input$site.phid),
                         format(input$date.phid, "%y%m%d"),
                         ifelse(nchar(input$sighting.phid==1),
                                paste0("0", input$sighting.phid),
                                input$sighting.phid))
      
      output$PhotoID <- renderText({paste(HTML("<font color=\"#FF0000\"><b>PHOTO ID<font color=\"#000000\"></b> assigned as: "), 
                                          HTML(paste0("<font color=\"#FF0000\"><b>",
                                                      phid$val,
                                                      "</b>")))})
      # output$PhotoID <- renderText({paste0(toupper(input$site.phid),
      #                                      format(input$date.phid, "%y%m%d"),
      #                                      ifelse(nchar(input$sighting.phid==1),
      #                                             paste0("0", input$sighting.phid),
      #                                             input$sighting.phid))})
      
      #return the photoID to splash around
      return(phid)
    }
  })
  output$finuploaded <- reactive({
    #hide the data entry tbl until essential info is included
    return(!is.null(finUP()) && grepl("^([A-Z]{2,3})([0-9]{8})", phid$val))
    #!is.na(input$sighting.phid))
  })
  outputOptions(output, 'finuploaded', suspendWhenHidden=F)
  
  output$dataentry <- DT::renderDataTable(
    formData(),
    rownames = FALSE,
    options = list(searching = FALSE, lengthChange = FALSE,
                   columnDefs=list(
                     list(visible = F, targets = c(14:17))))
  )
  
  #submit buttons only if fields are filled, theres a photo, & proper photoID
  observe({
    mandatoryFilled <- vapply(flds$mandatory,
                              function(x) {
                                
                                !is.null(input[[x]]) && input[[x]] != "" && !is.null(finUP())
                              },
                              logical(1))
    
    mandatoryFilled <- all(mandatoryFilled)
    
    # shinyjs::toggleState(id = "masfins", condition = mandatoryFilled)
    # shinyjs::toggleState(id = "r2submit", condition = mandatoryFilled)
  })
  
  ######################
  ######################
  ##Page 3 server stuff
  #build data frame, needs to become reactive
  #output$reviewed <- renderText({input$reviewed})
  #can we make this load sooner?? 
  
  
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
                # PhotoID = paste0(toupper(input$site.phid), 
                #                  format(input$date.phid, "%y%m%d"), 
                #                  ifelse(nchar(input$sighting.phid==1), 
                #                         paste0("0", input$sighting.phid),
                #                         input$sighting.phid)), 
                PhotoID = as.character(phid$val),
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
                dfN = file.path(paste0("CCA_GWS_PHID_", 
                                       #photoID
                                       # toupper(input$site.phid),
                                       # format(input$date.phid, "%y%m%d"), 
                                       # ifelse(nchar(input$sighting.phid==1), 
                                       #       paste0("0", input$sighting.phid),
                                       #       input$sighting.phid), 
                                       phid$val, "_",
                                       #timestamp
                                       as.integer(Sys.time()),
                                       #extension
                                       ".csv")),
                #photo file
                pFn = file.path(dropfin, paste0(phid$val, 
                                                ".", 
                                                tools::file_ext(input$fin.photo$datapath))),
                survey.crew = as.character(paste(input$crew, collapse = "|")),
                survey.effortON = as.character(input$effort.on),
                survey.effortOFF = as.character(input$effort.off),
                survey.notes = as.character(input$survey.notes)
      )
      data <- t(data)
      data
    }
  })
  
  
  ######################
  ######################
  ##Button doing stuff
  dB <- reactiveValues()
  dropdB <- reactive({loadData2(phid.only = phid$val)})
  #update page 3 from the get go
  output$finsTable <- DT::renderDataTable(
    loadData2(),
    rownames = F, options=list(searching=F, lengthChange=F)
  )
  
  #Observe "mas fins" event here
  observeEvent(input$masfins, {
    showNotification(paste(data$dfN, "being uploaded to", dropsc), 
                     #action = a(href="javascript:location.reload();", "Reload page"),
                     closeButton = F, type = "message", duration=9,
                     id = "datUP")
    data <- data.frame(formData(), stringsAsFactors = F)
    saveData2(data)
    
    savePhoto2(input$fin.photo, phid$val)
    showNotification(paste(phid$val, "photo uploaded to", dropfin), 
                     #action = a(href="javascript:location.reload();", "Reload page"), 
                     closeButton = F, type = "message", duration=9,
                     id = "phidUP")
    
    #append to database for review
    #dB <- dplyr::bind_rows(dB, data)
    
    #Page 3 Updates
    # output$finsTable <- DT::renderDataTable(
    #   #loadData2(),
    #   dB,
    #   rownames = F, options = list(searching=F, lengthChange=F)
    # )
    
    #update pg 3 
    # output$finsTable <- DT::renderDataTable(
    #   loadData(dd),
    #   rownames = FALSE,
    #   options = list(searching = FALSE, lengthChange = FALSE)
    # )
    
    
    #reset fields
    sapply(c("sighting", "sex", "size", "tag.exists", "tagdeployed", "tag.id",
             "tag.side", "biopsy", "biopsy.id", "notes", "tag.notes",
             "fin.photo", "PhotoID", "finuploaded", "match.sugg", "time", "FinShot"), 
           reset)
    output$FinShot <<- NULL
    output$dataentry <<- NULL
    output$PhotoID <<- NULL
    phid$val <<- NULL
    
    reset("data")
    reset("masfins")
    reset("r2submit")
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
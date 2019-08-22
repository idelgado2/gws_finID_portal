### This is the SERVER file for our groundUP file ###

library(shiny)
source("fin_shiny_fxns2.R")
shinyServer(
  function(input, output, session){
    
    ##~~~~~~~~~~~~~~~~~~~~~~~~##
    ##     VARIABLES HERE     ##
    ##~~~~~~~~~~~~~~~~~~~~~~~~##
    
    phid <- reactiveValues()  #reactive value to hold majority of user input values
    
    hide("reviewButton")      #hide review button to ensure it is not clicked before masfins is clicked once so that the temp csv file is created and site crash is avoided
    
    if(file.exists(paste0(finCSVPath,"test.csv"))){
      file.remove(paste0(finCSVPath,"test.csv"))
    }
    
    ##~~~~~~~~~~~~~~~~~~~~~~##
    ##     OUTPUTS HERE     ##
    ##~~~~~~~~~~~~~~~~~~~~~~##
    
    output$finishTable <- renderDataTable({read.csv(paste0(finCSVPath,"test.csv"), row.names = NULL)})  ##may not need this here, I will check right now
    
    
    ##############################################################
    ## HIDE DATA entry table until essential infor is included ###
    ##############################################################
    output$finuploaded <- reactive({
      return(!is.null(finUP()))
    })
    
    ########################################################
    ## Fin upload will continue to run even when hidden, ### 
    ## not exactly sure why we need this but we need it  ###
    ########################################################
    outputOptions(output, 'finuploaded', suspendWhenHidden=FALSE)
    
    #######################################################################
    ## Ouputs for chossen SURVEY SITE, SURVEY DATE, and generated FindID ##
    #######################################################################
    output$siteOutput.phid = renderUI(tags$p(tags$span(style="color:red", "SURVEY SITE"), "assigned as: ", tags$span(style="color:red", input$site.phid)))
    output$dateOutput.phid = renderUI(tags$p(tags$span(style="color:red", "SURVEY DATE"), "assigned as: ", tags$span(style="color:red", as.Date(input$date.phid, format = "%m-%d-%Y"))))
    output$path = renderText({
      inFile <- input$fin.photo
      ifelse (is.null(inFile), return(NULL), return(inFile$datapath))
    })
    
    
    ##~~~~~~~~~~~~~~~~~~~~##
    ##   FUNCTIONS HERE   ##
    ##~~~~~~~~~~~~~~~~~~~~##
    
    ####################################################################
    ## DATA SHOWING Function called 'finUP', This will check         ###
    ## if the a photo has been uploaded. Once a photo has been       ###
    ## uploaded it will assign all inputed values to a               ###
    ## reavctive values structure and will output the uploaded       ###
    ## photo on the the screen as well as the the Photo ID givin     ###
    ## to the photo, the leaflet map, to pinpoint location of        ###
    ## fin photo capture and a table at the bottom summarizing       ###
    ## the current fin photo information that will be submitted      ###
    ## to the current session. All map functionality is included     ###
    ## in this function, the actual map and OBSERVE EVENT associated ###
    ## with the map when clicking.                                   ###
    ####################################################################
    finUP <- reactive({
      if(is.null(input$fin.photo)){ #if there is no photo uploaded do not assign values yet
        return(NULL)
      }
      else{
        #assign reactive values
        phid$site <- input$site.phid
        phid$date <- input$date.phid
        phid$val <- paste0(toupper(input$site.phid),  #create Photo ID and assign to reactive value 'val'
                           format(input$date.phid, "%y%m%d"),
                           ifelse(nchar(input$sighting.phid==1),
                                  paste0("0", input$sighting.phid),
                                  input$sighting.phid))     
        output$FinShot <- renderImage({list(src = input$fin.photo$datapath)}, deleteFile = FALSE) #print uploaded photo
        output$PhotoID = renderUI(tags$p(tags$span(style="color:red", "PHOTO ID"), "assigned as: ", tags$span(style="color:red", phid$val)))  #print Photo ID
        
        ### LEAFLET MAP FUNCTIONALITY HERE ###
        ctr <- flds$coords[[input$site.phid]]
        output$map <- renderLeaflet({
          if(input$lat =="" || input$long ==""){ 
            leaflet() %>% 
              addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap=T)) %>%
              setView(lng=ctr[1,1], lat = ctr[1,2], zoom = 14)
          }
          else{
            phid$lat <- as.numeric(input$lat)
            phid$long <- as.numeric(input$long)
            leaflet() %>% 
              addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap=T)) %>%
              setView(lng=input$long, lat = input$lat, zoom = 14) %>%
              addPulseMarkers(data = click, lng=as.numeric(input$long), lat=as.numeric(input$lat), icon = makePulseIcon(), options = leaflet::markerOptions(draggable = F))
          }
          
        })
        
        output$dataentry <- renderDataTable(formData()) #print preview table to current information to view befor submitting to current session
        
        #########################################
        ## OBSERVER EVENT FOR MAP CLICK HERE, ###
        ## within the same function, I don't  ###
        ## know if we can move it out of this ###
        ## function, but this works here      ###
        #########################################
        observeEvent(input$map_click,{
          #capture click
          click <- input$map_click
          phid$lat <- click$lat
          phid$long <- click$lng
          #add to map
          leafletProxy('map') %>%
            clearMarkers() %>% 
            addPulseMarkers(data = click, lng=~lng, lat=~lat, icon = makePulseIcon(), 
                            options = leaflet::markerOptions(draggable = F))
          
          output$xyloc <- renderText({paste("lat: ",
                                            round(click$lat, 4),
                                            "| long: ",
                                            round(click$lng, 4)
          )
          })
          updateTextInput(session, "lat", value = round(click$lat, 4))  #update coordinates in input boxes depending on map click
          updateTextInput(session, "long", value = round(click$lng, 4))
        })
      }
    })
    
    
    #################################################
    ## DATA MAKING function 'formData', this will ###
    ## take all the inputed values and put        ###
    ## them into a data.frame called 'data'       ###
    #################################################
    formData <- reactive({
      if(is.null(finUP)){
        return(NULL)
      }else{
        data <- c(refID = "UNMATCHED",
                  name = "NONE_YET",
                  match.sugg = as.character(input$match.sugg), 
                  time.obs = as.character(input$time),
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
                  lat.approx = as.character(round(as.numeric(phid$lat), 4)),
                  long.approx = as.character(round(as.numeric(phid$long), 4)),
                  timestamp = epochTime(), 
                  dfN = file.path(paste0("CCA_GWS_PHID_", phid$val, "_",as.integer(Sys.time()),".csv")),
                  #pFn = file.path(dropfin, paste0(phid$val, ".", tools::file_ext(input$fin.photo$datapath))),
                  survey.vessel = as.character(input$vessel),
                  survey.crew = as.character(paste(input$crew, collapse = "|")),
                  survey.effortON = as.character(input$effort[1]), #w/ slider range
                  survey.effortOFF = as.character(input$effort[2]),
                  survey.notes = as.character(input$survey.notes)
                )
        data <- t(data)
        data
      }
    })

    
    
    ##~~~~~~~~~~~~~~~~~~~~~##
    ## OBSERVE EVENTS HERE ##
    ##~~~~~~~~~~~~~~~~~~~~~##

    
    ################################################
    ## OBSERVE EVENT for 'addFins' button      #####
    ## in SURVEY INFO Tab this will push the   #####
    ## user to the 'FIN ID ENTRY' Tab          #####
    ################################################
    observeEvent(
      input$addfins,
      {updateTabsetPanel(
        session = session,
        "form",
        selected = "Fin Photo Entry"
      )}
    )
    
    
    ##################################################################
    ## OBSERVE EVENT for 'masfins' button in FIN ID ENTRY Tab,     ###
    ## this will take the data.frame 'data' and pass it to         ### 
    ## saveData() function as well as the photo uploaded to        ### 
    ## savePhoto() function. These functions are located in        ### 
    ## file fin_shiny_fxns2.R and this will save the the data      ###
    ## to a temporary csv file and the photo to a separate folder. ### 
    ## The paths can be changed at the top of fin_shiny_fxns2.R    ###
    ##################################################################
    observeEvent(input$masfins, {
      data <- data.frame(formData(), stringsAsFactors = F)    #save data to a dataframe in local varibale to pass to functions
      showNotification(paste(data$dfN, "being uploaded to server"), 
                       closeButton = F, type = "message", duration=2,
                       id = "datUP")
      saveData(data)  #save data
      savePhoto(input$fin.photo, phid$val)  #save photo
      
      show("reviewButton")  #Show review button after initial masfins/addfin click is made to ensure that temp csv file is created to prevent from potential crashing
      
      #reset fields
      sapply(c("sex", "size", "tag.exists", "tagdeployed", "tag.id","tag.side",
               "biopsy", "biopsy.id", "notes", "tag.notes","finuploaded", "fin.photo", "PhotoID", "match.sugg", "time", "FinShot"), reset)
      
      updateNumericInput(session, "sighting.phid", value = (input$sighting.phid + 1))   #increase sigting by one everytime we want to add another fin entry
      runjs("window.scrollTo(0, 50)")   #scroll to top of the window after reseting everything
      

      output$FinShot <- NULL
      output$dataentry <- NULL
      output$PhotoID <- NULL
      phid$val <- NULL
      
      
      #reset("data")
      #reset("masfins")
    })
    
    ####################################################################
    ## OBSERVE EVENT for 'r2submit' (review to submit) button in     ###
    ## FIN ID ENTRY Tab, this will read the temporary csv file       ###
    ## created by 'masfins' button into a data.frame called 'mydata' ###
    ## and then render an editable table (handsontable) in the       ### 
    ## DATA SUBMISSION tab. This even will also push the user to the ###
    ## DATA SUBMISSION tab as well.                                  ###
    ####################################################################
    observeEvent(input$r2submit, {
      mydata <- read.csv(file=paste0(finCSVPath,"test.csv"), header=TRUE, sep=",", stringsAsFactors = FALSE, row.names = NULL) #this is called to load the data table in the Data Submission page
      Sys.sleep(1)  #forcing program to sleep for a second in order to let test csv file to be created and identified in time to render the table
      output$hotTable <- renderRHandsontable({
        rhandsontable(mydata) %>%  # converts the R dataframe to rhandsontable object
          hot_col("PhotoID", readOnly = TRUE) %>%
          hot_col("site", readOnly = TRUE) %>%
          hot_col("date", readOnly = TRUE) %>%
          hot_col("sighting", readOnly = TRUE) %>%
          hot_context_menu(allowRowEdit = TRUE, allowColEdit = FALSE)
      })
      updateTabsetPanel(session, "form", selected = "Data Submission")      #move user to submission page
    })
    
    #############################################################################
    ## OBSERVE EVENT for 'serverSubmit' button in DATA SUBMISSION Tab,        ###
    ## this will write to a new permenant CSV file using the newly            ###
    ## created table. We use the table here instead of the previous           ###
    ## data.frame because the user may edit the information in the table.     ###
    ## This event will also delete the temporary csv file previously created. ###
    ## Lastly, this will push the user to the SURVEY INFO tab to start over.  ###
    #############################################################################
    observeEvent(input$serverSubmit,{
      write.table(hot_to_r(input$hotTable), file = paste0(finCSVPath, paste0(as.character(Sys.time()),"_FinID.csv")),
                  row.names = FALSE, col.names = TRUE, quote = TRUE, append=FALSE, sep = ",")   # write table to new csv file

      file.remove(paste0(finCSVPath,"test.csv"))    #delete temporary filed
      shinyalert::shinyalert(title = "Uploading To Server", text = "", type = "success", closeOnEsc = FALSE,
                             closeOnClickOutside = FALSE, html = FALSE, showCancelButton = FALSE,
                             showConfirmButton = FALSE, timer = 3000,
                             animation = TRUE)    #notification to user
      updateTabsetPanel(session, "form", selected = "Survey Info")  #move to initial tab
    })
    
    ########################################################################
    ## OBSERVER for insuring that all mandatory items are filled in.     ###
    ## This may need to be revisioned, all fields are now filled in by   ###
    ## default to ensure editability in the table in DATA SUBMISSION tab ###
    ## Thus, this observer may not be necessary at this point            ###
    ########################################################################
    observe({
      mandatoryFilled <- vapply(flds$mandatory,
                                function(x) {
                                  !is.null(input[[x]]) && input[[x]] != "" && !is.null(finUP())
                                },
                                logical(1))
      mandatoryFilled <- all(mandatoryFilled)
    })
  }
)









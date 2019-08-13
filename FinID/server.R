### This is the SERVER file for our groundUP file ###

library(shiny)
source("fin_shiny_fxns2.R")
shinyServer(
  function(input, output, session){
    #setAccountInfo(name='idelgado',
    #               token='B911B9733B6FCF8B67DCA5BF861A1AD9',
    #               secret='itTB3/LHML67EOMxXkJkrqOLhD+L7w58wvaoqXvW')
    
    phid <- reactiveValues()

    finUP <- reactive({
      if(is.null(input$fin.photo)){
        return(NULL)
      }
      else{
        phid$site <- input$site.phid
        phid$date <- input$date.phid
        phid$val <- paste0(toupper(input$site.phid),
                             format(input$date.phid, "%y%m%d"),
                             ifelse(nchar(input$sighting.phid==1),
                                    paste0("0", input$sighting.phid),
                                    input$sighting.phid))
        output$FinShot <- renderImage({list(src = input$fin.photo$datapath)}, deleteFile = FALSE)
        output$PhotoID = renderUI(tags$p(tags$span(style="color:red", "PHOTO ID"), "assigned as: ", tags$span(style="color:red", phid$val)))
        
        ctr <- flds$coords[[input$site.phid]]
        output$map <- renderLeaflet({
          if(input$lat =="" || input$long ==""){ ###why is it not coming into this if statement???#####
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
        
        output$dataentry <- renderDataTable(formData())
        
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
          updateTextInput(session, "lat", value = round(click$lat, 4))
          updateTextInput(session, "long", value = round(click$lng, 4))
        })
      }
    })
    
    output$finuploaded <- reactive({
      #hide the data entry tbl until essential info is included
      return(!is.null(finUP()))
    })
    outputOptions(output, 'finuploaded', suspendWhenHidden=F)
    
    #output$dataentry <- renderDataTable(formData())
    
    output$siteOutput.phid = renderUI(tags$p(tags$span(style="color:red", "SURVEY SITE"), "assigned as: ", tags$span(style="color:red", input$site.phid)))
    output$dateOutput.phid = renderUI(tags$p(tags$span(style="color:red", "SURVEY DATE"), "assigned as: ", tags$span(style="color:red", as.Date(input$date.phid, format = "%m-%d-%Y"))))
    
    output$path = renderText({
      inFile <- input$fin.photo
      ifelse (is.null(inFile), return(NULL), return(inFile$datapath))
    })
    

    ##### action instruction for addFins button #####
    observeEvent(
      input$addfins,
        {updateTabsetPanel(
        session = session,
        "form",
        selected = "Fin Photo Entry"
        )}
    )
    
    ##### Data Making Here, for table and storage ####
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
################################################################################################
    
    observeEvent(input$masfins, {
      data <- data.frame(formData(), stringsAsFactors = F)
      showNotification(paste(data$dfN, "being uploaded to server"), 
                       #action = a(href="javascript:location.reload();", "Reload page"),
                       closeButton = F, type = "message", duration=9,
                       id = "datUP")
      saveData(data)
      savePhoto(input$fin.photo, phid$val)
      
      #reset fields
      sapply(c("sex", "size", "tag.exists", "tagdeployed", "tag.id","tag.side",
               "biopsy", "biopsy.id", "notes", "tag.notes","finuploaded", "fin.photo", "PhotoID", "match.sugg", "time", "FinShot"), reset)
      
      updateNumericInput(session, "sighting.phid", value = (input$sighting.phid + 1))
      runjs("window.scrollTo(0, 50)")   #scroll to top of the window after reseting everything
      

      output$FinShot <- NULL
      output$dataentry <- NULL
      output$PhotoID <- NULL
      phid$val <- NULL
      
      
      
      #reset("data")
      #reset("masfins")
    })
    
    observeEvent(input$r2submit, {
      observe({
        shinyjs::click("masfins")})      #click masfins to save photo/data
      updateTabsetPanel(session, "form", selected = "Data Submission")      #move user to submission page
      output$finishTable <- renderTable({read.csv(paste0(finCSVPath,"/test.csv"))})
    })
    
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









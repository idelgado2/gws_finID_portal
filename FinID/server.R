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
        phid$dummy <- paste0(toupper(input$site.phid),
                             format(input$date.phid, "%y%m%d"),
                             ifelse(nchar(input$sighting.phid==1),
                                    paste0("0", input$sighting.phid),
                                    input$sighting.phid))
        output$FinShot <- renderImage({list(src = input$fin.photo$datapath)}, deleteFile = FALSE)
        output$PhotoID = renderUI(tags$p(tags$span(style="color:red", "PHOTO ID"), "assigned as: ", tags$span(style="color:red", phid$dummy)))
        
        ctr <- flds$coords[[input$site.phid]]
        output$map <- renderLeaflet({
          leaflet() %>% 
          addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(noWrap=T)) %>%
          setView(lng=ctr[1,1], lat = ctr[1,2], zoom = 14)
        })
        
        observeEvent(input$map_click,{
          #capture click
          click <- input$map_click
          phid$lat <- click$lat
          phid$long <- click$lng
          #print("pos is", clat, clong)
          #add to map
          leafletProxy('map') %>%
            clearMarkers() %>% 
            addPulseMarkers(data = click, lng=~lng, lat=~lat, icon = makePulseIcon(), 
                            options = leaflet::markerOptions(draggable = F))
          #MIGHT NOT UPDATE LOC?? make draggable false
          
          output$xyloc <- renderText({paste("lat: ", round(click$lat, 4),
                                            "| long: ", round(click$lng, 4))})
          
        })
      }
    })
    
    output$finuploaded <- reactive({
      #hide the data entry tbl until essential info is included
      return(!is.null(finUP()))
    })
    outputOptions(output, 'finuploaded', suspendWhenHidden=F)

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
  }
)
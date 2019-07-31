library(shiny)
library(rsconnect)
library(DT)
source("fin_shiny_fxns2.R")
#mostly here: https://deanattali.com/2015/06/14/mimicking-google-form-shiny/
#upload support: https://shiny.rstudio.com/articles/upload.html


#saving data
#saving response
fieldsAll <- c("user", "site.phid", "date.phid", "sighting.phid", #"fin.photo",
               "sex", "size", "tag.exists", "tag.deployed", 
               "tag.id", "tag.notes", "biopsy", "observer", "notes")

#define where to find things
dd <- file.path("entries")
fN = "here_lies_data.csv"
shinyApp(ui = fluidPage(
  #shinyjs::useShinyjs(),
  #shinyjs::inlineCSS(appCSS),
  titlePanel("FinID Data Entry"),
  #tabling?  maybe stow at the bottom? 
  #DT::dataTableOutput("responsesTable"),
  sidebarLayout(
    sidebarPanel(
      id = "form",
      
      checkboxGroupInput("observer", "Observer", choices = c("PK", "SA", "SJ", "JM", "TW", "TC", "EM"), 
                         inline = T), #can select multiple
      #fileupload here
      # textInput("daynotes", "Survey notes", placeholder = "e.g. notes about the survey todayc", 
      #           width = "600px"),
      selectInput("site", "Monitoring Site", choices = c("PR", "FAR", "AN", "APT")),
      dateInput("date", "Date", value = Sys.Date(), format = "yyyy-mm-dd"),
      textInput("sighting", "Sighting #", placeholder = "0?"), #MAKE THIS NUMERIC?
      textInput("matchnotes", "Match notes?", placeholder = "handle, tag #?", 
                width = "600px"),
      textInput("time", "Time of Sighting", placeholder = "0900"), #MAKE THIS NUMERIC   d?
      fileInput("fin.photo", "Upload Fin Photo here",
                multiple = FALSE,
                accept = c("image/jpeg", "image/png", "image/tiff",
                           ".jpeg", ".jpg", ".png", ".tiff")),
      selectInput("sex", "Sex (U if unknown)", choices = c("M", "F", "U"), 
                  selectize = F, selected = "U"), 
      sliderInput("size", "Size (in ft)", value = 13.0, min = 4, max = 20, step = 0.5),
      textInput("notes", "Notes", placeholder = "e.g. pings heard, secondary marks, scars, nicknames, etc", 
                width = "600px"),
      selectInput("tag.exists", "Tagged Already?", choices = c("U", "Y"), selected = "U"),
      selectInput("tagdeployed", "New Tag?", choices = c("None", "PAT", "Acoustic", "Stomach", "Clamp"), selected = "NONE"),
      #make ^ check box and conditional panel for each tag selected?
      conditionalPanel(
        condition = "input.tagdeployed != 'None'",
        checkboxGroupInput("tag.side", "Deployed On? ", choices = c("L", "R"), 
                           inline = T), #can select multiple
        textInput("tag.id", "Tag ID#"),
        textInput("tag.notes", "Tagging Notes", width = '600px', 
                  placeholder = "e.g., programming params, Ptt/SPOT used, orientation"),
        selectInput("biopsy", "Biopsy?", choices = c("N", "Y"))
      ),

      actionButton("masfins", "Mas Fins?", class="btn-primary"),
      actionButton("submit", "Submit", class = "btn-primary")
    ),
    mainPanel(
      textOutput("PhotoID"),
      imageOutput(outputId = "FinShot"),
      DT::dataTableOutput("responsesTable")
    )
  )#,
  # div(id = "form"),
  # shinyjs::hidden(
  #   div(
  #     id = "submit_msg",
  #     h3("New Fin Photo captured!"),
  #     actionLink("submit_another", "Submit data")
  #   )
  # )  
),
server = function(input, output, session) {
  re1 <- reactive({gsub("\\\\","/", input$fin.photo$datapath)})
  #make photoID stamp
  output$PhotoID <- renderText({paste0(toupper(input$site), 
                                       format(input$date, "%y%m%d"), 
                                       sprintf("%02s", input$sighting))})
  #render the fin
  output$FinShot <- renderImage({list(src = re1())})
  #render the data
  # output$responsesTable <- DT::renderDataTable(
  #   loadData(),
  #   rownames = FALSE,
  #   options = list(searching = FALSE, lengthChange = FALSE)
  # )
  
  # formPhoto <- function(fin)({
  #   #plotPNG at least creates a file
  #   photo <- plotPNG(renderImage(fin$datapath),
  #                    filename = "/Users/jmoxley/Downloads/here_lies_photo.png")
  #   photo
  #   })
  #make data entry row
  formData <- reactive({
    #save photo
    ###HERE!!!
    
    data <- c(refID = "UNMATCHED", name = "AWAITING MATCH", 
              PhotoID = paste0(toupper(input$site), 
                               format(input$date, "%y%m%d"), 
                               sprintf("%02s", input$sighting)), 
              site.phid = as.character(input$site), 
              date.phid = as.character(input$date), 
              sighting.phid = as.character(sprintf("%02s",input$sighting))
              #REST O DATA
              #timestamp = epochTime()
              )
    data <- t(data)
    print(data)
  })
  
  renderPrint(formData())
  
  # action to take when submit button is pressed
  observeEvent(input$submit, {
    #savePhoto(formPhoto(input$fin.photo))
    dat <- as.data.frame(formData())
    saveData(dat)
    # shinyjs::reset("form")
    # shinyjs::hide("form")
    # shinyjs::show("thankyou_msg")
  })

  #action upon submit button is pressed
  # observeEvent(input$submit, {
  #   saveData(formData())
  # })
  
  #do the form again
  # observeEvent(input$submit_another, {
  #   shinyjs::show("form")
  #   shinyjs::hide("thankyou_msg")
  # })    
}
)
#shinyApp(ui, server)
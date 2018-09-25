library(shiny)
library(rsconnect)
library(DT)
#mostly here: https://deanattali.com/2015/06/14/mimicking-google-form-shiny/
#upload support: https://shiny.rstudio.com/articles/upload.html

# #set mandatory, does not work right now
# fieldsMandatory <- c("observer", "site", "date", "sighting", "fin.photo")
# labelMandatory <- function(label){
#   tagList(
#     label,
#     span("*", class = "mandatory_star")
#   )
# }
# appCSS <-
#   ".mandatory_star { color: red; }"


#saving data
#saving response
# fieldsAll <- c("site", "date", "sighting", #"fin.photo", 
#                "sex", "size", "tag.exists", 
#                "tagdeployed", "tag.id", "tag.notes", "biopsy", "observer", "notes")
responseDir <- file.path("entries")
#time functions
epochTime <- function(){
  as.integer(Sys.time())
}
humanTime <- function() format(Sys.time(), "%Y%m%d-%H%M%OS")
#save fxn
#saving
saveData <- function(data){
  fileName <- sprintf("here_lies_data.csv")
  write.csv(x = data, file=file.path(responseDir, fileName),
            row.names = F, quote = T)
}
savePhoto <- function(photo){
  png("/Users/jmoxley/Downloads/here_lies_photo.png")
  fileName <- sprintf("here_lies_photo.png")
  file.copy(photo, "/Users/jmoxley/Downloads/here_lies_photo.png")
  dev.off()
}
loadData <- function() {
  files <- list.files(file.path(responseDir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- dplyr::rbind_all(data)
  data
}

shinyApp(ui = fluidPage(
  #shinyjs::useShinyjs(),
  #shinyjs::inlineCSS(appCSS),
  titlePanel("FinID Data entry"),
  #tabling?  maybe stow at the bottom? 
  #DT::dataTableOutput("responsesTable"),
  sidebarLayout(
    sidebarPanel(
      id = "form",
      
      checkboxGroupInput("observer", "Observer", choices = c("PK", "SA", "SJ", "JM", "TW", "TC", "EM"), 
                         inline = T), #can select multiple
      #fileupload here
      selectInput("site", "Monitoring Site", choices = c("PR", "FAR", "AN", "APT")),
      dateInput("date", "Date", value = Sys.Date(), format = "yyyy-mm-dd"),
      textInput("sighting", "Sighting #", placeholder = "0?"), #MAKE THIS NUMERIC?
      fileInput("fin.photo", "Upload Fin Photo here",
                multiple = FALSE,
                accept = c("image/jpeg", "image/png", "image/tiff",
                           ".jpeg", ".jpg", ".png", ".tiff")),
      
      selectInput("sex", "Sex (Select U if unknown/not observed)", choices = c("M", "F", "U"), 
                  selectize = F, input = "U"), 
      sliderInput("size", "Size (in ft)", value = 13.0, min = 4, max = 20, step = 0.5),
      textInput("notes", "Notes", placeholder = "e.g. pings heard, secondary marks, scars, nicknames, etc", 
                width = "600px"),
      selectInput("tag.exists", "Tagged Already?", choices = c("U", "Y"), selected = "U"),
      selectInput("tagdeployed", "New Tag?", choices = c("None", "PAT", "Acoustic", "Stomach", "Clamp"), selected = "NONE"),
      #make ^ check box and conditional panel for each tag selected?
      conditionalPanel(
        condition = "input.tagdeployed != 'None'",
        textInput("tag.id", "Tag ID#"),
        textInput("tag.notes", "Tagging Notes", width = '600px', 
                  placeholder = "e.g., programming params, Ptt/SPOT used, orientation"),
        selectInput("biopsy", "Biopsy?", choices = c("N", "Y"))
      ),

      actionButton("masfins", "More Fins?", class="btn-primary"),
      actionButton("submit", "Submit", class = "btn-primary")
    ),
    mainPanel(
      textOutput("PhotoID"),
      imageOutput(outputId = "FinShot")
    )
  ),
  div(id = "form"),
  shinyjs::hidden(
    div(
      id = "submit_msg",
      h3("New Fin Photo captured!"),
      actionLink("submit_another", "Submit data")
    )
  )  
),
server = function(input, output, session) {
  re1 <- reactive({gsub("\\\\","/", input$fin.photo$datapath)})
  output$PhotoID <- renderText({paste0(toupper(input$site), 
                                       format(input$date, "%y%m%d"), 
                                       sprintf("%02s", input$sighting))})
  output$FinShot <- renderImage({list(src = re1())})
  
  
  # #build a table of the data
  # output$responsesTable <- DT::renderDataTable(
  #   loadData(),
  #   rownames = FALSE,
  #   options = list(searching = FALSE, lengthChange = FALSE)
  # ) 
  
  
  

  formPhoto <- function(fin)({
    #plotPNG at least creates a file
    photo <- plotPNG(renderImage(fin$datapath),
                     filename = "/Users/jmoxley/Downloads/here_lies_photo.png")
    photo
  })
  #make data entry row
  formData <- reactive({
    #save photo
    #data <- sapply(fieldsAll, function(x) input[[x]])
    data <- c(refID = "UNMATCHED", PhotoID = paste0(toupper(input$site), 
                                                    format(input$date, "%y%m%d"), 
                                                    sprintf("%02s", input$sighting)), 
              site = as.character(input$site), date = as.character(input$date), 
              sighting = as.character(sprintf("%02s",input$sighting)),
              #data, 
              timestamp = epochTime())
    data <- t(data)
    data
  })
  
  
  # action to take when submit button is pressed
  observeEvent(input$submit, {
    savePhoto(formPhoto(input$fin.photo))
    saveData(formData())
    shinyjs::reset("form")
    shinyjs::hide("form")
    shinyjs::show("thankyou_msg")
  })

  #action upon submit button is pressed
  # observeEvent(input$submit, {
  #   saveData(formData())
  # })
  
  #do the form again
  observeEvent(input$submit_another, {
    shinyjs::show("form")
    shinyjs::hide("thankyou_msg")
  })    
}
)
#shinyApp(ui, server)
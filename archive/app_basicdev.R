#attempt to develop a shiny app data entry
#https://shiny.rstudio.com/articles/upload.html
#https://deanattali.com/2015/06/14/mimicking-google-form-shiny/
#JHMoxley, 20 Sept 2018

library(shiny)
library(rsconnect)

shinyApp(ui = fluidPage(
  titlePanel("FinID Data entry"),
  div(
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
                value = "e.g., programming params, Ptt/SPOT used, orientation"),
      selectInput("biopsy", "Biopsy?", choices = c("N", "Y"))
    ),
    actionButton("submit", "Submit", class = "btn-primary")
    #mainPanel(imageOutput("FinPhoto"))
  )
),
server = function(input, output, session) {

}
)




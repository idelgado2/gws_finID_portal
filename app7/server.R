### This is the SERVER file for our groundUP file ###

library(shiny)
library(rsconnect)
source("fin_shiny_fxns2.R")
shinyServer(
  function(input, output, session){
    setAccountInfo(name='idelgado',
                   token='B911B9733B6FCF8B67DCA5BF861A1AD9',
                   secret='itTB3/LHML67EOMxXkJkrqOLhD+L7w58wvaoqXvW')
    
    output$siteOutput.phid = renderUI(tags$p(tags$span(style="color:red", "SURVEY SITE"), "assigned as: ", tags$span(style="color:red", input$site.phid)))
    output$dateOutput.phid = renderUI(tags$p(tags$span(style="color:red", "SURVEY DATE"), "assigned as: ", tags$span(style="color:red", as.Date(input$date.phid, format = "%m-%d-%Y"))))
    
    #renderUI(tags$h3("Hello There",tags$b("Isaac")))

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
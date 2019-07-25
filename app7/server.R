### This is the SERVER file for our groundUP file ###

library(shiny)
library(rsconnect)
shinyServer(
  function(input, output){
    setAccountInfo(name='idelgado',
                   token='B911B9733B6FCF8B67DCA5BF861A1AD9',
                   secret='itTB3/LHML67EOMxXkJkrqOLhD+L7w58wvaoqXvW')
    output$myName = renderText(input$name)
    output$myAge = renderText(input$age)
    output$myGender = renderText(input$gender)
    
    output$mySliderValue = renderText(paste("You selected value: ", input$slide))
  }
)
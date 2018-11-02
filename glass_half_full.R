library(shiny)
library(ggplot2)
library(magrittr)

ui =pageWithSidebar(
  headerPanel("Take our quiz to find out if you're an optimist or pessimist"),
  sidebarPanel(
    sliderInput(inputId = "Full", label = "% water", min = 0, max = 1, value = 0.31),
    sliderInput(inputId = "Empty", label = "% air", min = 0, max = 1, value = 1 - 0.31),
    uiOutput("Empty")),
  mainPanel(
    plotOutput("glass")
  )
)

server = function(input, output, session){
  
  # when water change, update air
  observeEvent(input$Full,  {
    updateSliderInput(session = session, inputId = "Empty", value = 1 - input$Full)
  })
  
  # when air change, update water
  observeEvent(input$Empty,  {
    updateSliderInput(session = session, inputId = "Full", value = 1 - input$Empty)
  })
  
  #make data
  outlook <- reactive({
    dat <- data.frame(medium = c("air", "water"), 
                      amt = c(input$Empty, input$Full) 
                      )
    dat
  })
  #plot
  output$glass <- renderPlot({
    outlook() %>% ggplot() + geom_col(aes(x = "", y = amt, fill = medium)) +
      scale_fill_manual(values =  c("#E0FFFE", "#40A4DF"))+
      scale_y_continuous(limits = c(0,1), breaks = seq(0,1,0.1))
  })
}

shinyApp(ui = ui, server = server)
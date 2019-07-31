library(shiny)
library(ggplot2)
library(magrittr)
library(lubridate)
yrs <- c(2009, 2015, 2016)
yr.stamp <- function(x, t){
  x <- as.POSIXlt(x)
  year(x) <- yrs[which(yrs == as.numeric(t))]
  as.Date(x)
}

ui = pageWithSidebar(
  headerPanel("Doing dates like a pro"),
  sidebarPanel(
    dateInput("md", label = "Date", 
              value = Sys.Date(), format = "mm-dd"),
    sliderInput("md2", label = 'date slider', 
                min = 1,
                max = 365,
                value = 77,
                step = 1),
    sliderInput("md2", label = 'date slider', 
                min = as.Date("2018-01-01"),
                max = as.Date("2018-12-31"),
                value = as.Date("2018-03-17"),
                step = 1,
                timeFormat="%m-%d"),
    selectInput("t", label = "which year, yo", 
                choices = c("2009", "2015", "2016"), selected = NULL)
    #could put check boxes here if you want to select which years
  ),
  mainPanel(
    textOutput("dt"),
    textOutput("dt1"),
    textOutput("dt2")
  )
)


server = function(input, output, session){
  
  output$dt<- renderText(paste("my month & date are:", 
                               strftime(
                                 input$md, 
                                 format = "%m-%d")))

  #wuts that?? you want years too
  
  
  output$dt1 <- renderText({paste("wit da year", 
                                  strftime(yr.stamp(input$md, t=input$t), 
                                           format = "%m-%d-%Y"))})
  
  #convert slider into a date
  output$dt2 <- renderText({paste("you selected", 
                                  yr.stamp(as.Date(input$md2, format = "%m-%d", 
                                          origin = as.Date("2018-01-01")),
                                  t = input$t))})
}

shinyApp(ui = ui, server = server)
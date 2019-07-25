### This is the UI file for our groundUP file ###

library(shiny)
library(rsconnect)

shinyUI(
  fluidPage(
    titlePanel(title = "Hello this is my first shiny app, Hello Shiny!"),
    sidebarLayout(
      sidebarPanel(h3("Enter personal information"),
                   textInput("name", h4("Enter Your Name"), ""),
                   textInput("age", h4("Enter Your Age"), ""),
                   radioButtons("gender", "Select your gender",list("Male", "Female") , ""),
                   sliderInput("slide", "Select the value from the slider", min = 0, max = 5, value = 2, step = 0.2, animate = TRUE)
      ),
      mainPanel(h3("Personal Information"),
                textOutput("myName"),
                textOutput("myAge"),
                textOutput("myGender"),
                textOutput("mySliderValue"))
    )
  )
)

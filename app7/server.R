### This is the SERVER file for our groundUP file ###

library(shiny)
library(rsconnect)
shinyServer(
  function(input, output){
    setAccountInfo(name='idelgado',
                   token='B911B9733B6FCF8B67DCA5BF861A1AD9',
                   secret='itTB3/LHML67EOMxXkJkrqOLhD+L7w58wvaoqXvW')
    output$site.phid = renderText({
                          paste(
                            HTML("<font color=\"#FF0000\"><b>SURVEY SITE<font color=\"#000000\"></b> assigned as: "),
                            HTML(
                              paste0(
                                "<font color=\"#FF0000\"><b>",
                                input$site.phid,
                                "<b>"
                              )
                            )
                          )
                        }
                      )
    output$date.phid = renderText({
                          paste(
                            HTML("<font color=\"#FF0000\"><b>SURVEY DATE<font color=\"#000000\"></b> assigned as: "), 
                            HTML(
                              paste0(
                                "<font color=\"#FF0000\"><b>",
                                as.Date(input$date.phid, format = "%m-%d-%Y"),
                                "</b>"
                              )
                            )
                          )
                        }
                      )
  }
)
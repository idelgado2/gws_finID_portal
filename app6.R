library(shiny)
library(DT) 
runApp(list(
  ui = basicPage(
    h2('The mtcars data'),
    DT::dataTableOutput('mytable'),
    h2("Selected"),
    tableOutput("checked")
  ),
  
  server = function(input, output) {
    # helper function for making checkbox
    shinyInput = function(FUN, len, id, ...) { 
      inputs = character(len) 
      for (i in seq_len(len)) { 
        inputs[i] = as.character(FUN(paste0(id, i), label = NULL, ...)) 
      } 
      inputs 
    } 
    # datatable with checkbox
    output$mytable = DT::renderDataTable({
      data.frame(mtcars,Rating=shinyInput(selectInput,nrow(mtcars),"selecter_",
                                          choices=1:5, width="60px"))
    }, selection='none',server = FALSE, escape = FALSE, options = list( 
      paging=TRUE,
      preDrawCallback = JS('function() { 
                           Shiny.unbindAll(this.api().table().node()); }'), 
      drawCallback = JS('function() { 
                        Shiny.bindAll(this.api().table().node()); } ') 
      ) )
    # helper function for reading checkbox
    shinyValue = function(id, len) { 
      unlist(lapply(seq_len(len), function(i) { 
        value = input[[paste0(id, i)]] 
        if (is.null(value)) NA else value 
      })) 
    } 
#clean sheet to help functional development
require(shiny)
require(rsconnect)
require(DT)
require(shinyTime)
require(shinyjs)

#list of observers available to checkbox
flds <- list(
  observers = c("PK", "SA", "SJ", "JM", "TC", "TW", "EM", "OJ"),
  sites = c("PR", "FAR", "AN", "APT")
)

entries <- list(
  #list(id = "site.phid", type = "select", title = "Monitoring Site", choices = flds$sites),
  list(id = "date.phid", type = "date", title = "Date", value = Sys.Date(), format = "yyyy-mm-dd"),
  list(id = "sighting", type = "text", title = "Sighting #", placeholder = "0?"),
  list(id = "matchsugg", type = "text", title = "Suggested Match", placeholder = "handle, tag#?"),
  list(id = "time", type = "text", title = "Time of sighting", placeholder = "0915")
  #list(id = "sex", type = "select", title = "Sex (U if unknown", choices = c("U","M","F"), selected="U"),
  #list(id = "size", type = )
)

#question maker, based on internal code of formUI in shinyforms
#https://github.com/daattali/shinyforms/blob/master/R/shinyform.R
qMaker <-  function(question) {
  label <- question$title
  # if (question$id %in% fieldsMandatory) {
  #   label <- labelMandatory(label)
  # }
  
  if (question$type == "text") {
    input <- textInput(ns(question$id), NULL, "")
  } else if (question$type == "numeric") {
    input <- numericInput(ns(question$id), NULL, 0)
  } else if (question$type == "checkbox") {
    input <- checkboxInput(ns(question$id), label, FALSE)
  } else if(question$type == "date"){
    input <- dateInput(ns(question$id), NULL, 
                       format = question$format, value = question$value)
  } else if(question$type == "select"){
    input <- selectInput(ns(question$id), NULL, choices = )
  }
  
  div(
    class = "sf-question",
    if (question$type != "checkbox") {
      tags$label(
        `for` = ns(question$id),
        class = "sf-input-label",
        label,
        if (!is.null(question$hint)) {
          div(class = "question-hint", question$hint)
        }
      )
    },
    input
  )
}

  
  
labelMandatory <- function(label) {
    tagList(
      label,
      span("*", class = "mandatory_star")
  )
}

#get data
loadData <- function(dir) {
  #add pattern for unique fN for survey
  files <- list.files(file.path(dir), full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE)
  data <- dplyr::bind_rows(data)
  data
}



############
##STORAGE FXNS
############
#write & save data (if no file)
saveData <- function(dat){
  #fileName <- sprintf("here_lies_data.csv")
  # write.table(x = dat, file=file.path(dd, fN),
  #             row.names = F, quote = T, append=T, sep = ",")
  dat <- as.data.frame(dat)
  if(file.exists(file.path(dd, fN))){
    #append if file exists
    write.table(x = dat, file=file.path(dd, fN),
                row.names = F, col.names = F,
                quote = T, append=T, sep = ",")
    # file.create(file.path(dd, 'igothere.csv'))
  }else{
    #write csv if file doesn't
    write.table(dat, file = file.path(dd, fN),
                row.names = F, col.names = T,
                quote = T, append=F, sep = ",")
  }
}

#timestamping
epochTime <- function(){
  as.integer(Sys.time())
}
  
#####
#RESOURCES
#####
#https://github.com/daattali/shinyforms/blob/master/R/shinyform.R
#https://github.com/JayMox/shinyforms
#Multiple user lock out: https://community.rstudio.com/t/persistent-data-storage-in-apps-with-multiple-users/1308
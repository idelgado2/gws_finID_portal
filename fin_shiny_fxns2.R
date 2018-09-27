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

##
#attempt to generalize
entries <- list(
  #list(id = "site.phid", type = "select", title = "Monitoring Site", choices = flds$sites),
  list(id = "date.phid", type = "date", title = "Date", value = Sys.Date(), format = "yyyy-mm-dd"),
  list(id = "sighting", type = "text", title = "Sighting #", placeholder = "0?"),
  list(id = "matchsugg", type = "text", title = "Suggested Match", placeholder = "handle, tag#?"),
  list(id = "time", type = "text", title = "Time of sighting", placeholder = "0915")
  #list(id = "sex", type = "select", title = "Sex (U if unknown", choices = c("U","M","F"), selected="U"),
  #list(id = "size", type = )
)


  
  
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
#save photo uploads w/ photoID
savePhoto <- function(photo){
  png("/Users/jmoxley/Downloads/here_lies_photo.png")
  fileName <- sprintf("here_lies_photo.png")
  file.copy(photo, "/Users/jmoxley/Downloads/here_lies_photo.png")
  dev.off()
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
#reset https://stackoverflow.com/questions/49344468/resetting-fileinput-in-shiny-app
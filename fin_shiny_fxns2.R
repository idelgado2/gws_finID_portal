#clean sheet to help functional development
require(shiny)
require(rsconnect)
require(DT)
require(shinyTime)
require(shinyjs)
require(rdrop2)

#dirs
#dropbox spot
dropdd <- "FinID_curator/archive"
dropsc <- "FinID_curator/scratch"
dropfin <- "FinID_curator/FinIDs_staging"

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
#dropbox load
loadData2 <- function(fileName) {
  print(fileName)
  #add pattern for unique fN for survey
  data <- drop_read_csv(file.path(dropsc, fileName))
  data
}



############
##STORAGE FXNS
############
#write & save data (if no file); LOCALLY
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
#using dropbox
saveData2 <- function(data) {
  # get positioned
  data <- data.frame(data, as.is = T, stringsAsFactors = F)
  orig.n <- nrow(data)
  dropPath <- file.path(dropsc, data$fN)
  tempPath <- file.path(tempdir(),
                        data$fN)
  print(paste("storing data in this file", dropPath))
  
  if(drop_exists(dropPath)){
    #read, append, and upload
    dropdat <- drop_read_csv(dropPath)
    data <- rbind(dropdat, data)
    if(nrow(data) > nrow(dropdat)){
      #update only if successfully appended data
      write.csv(data, tempPath, row.names = FALSE, quote = TRUE)
      }
    drop_upload(tempPath, path = dropsc, mode = "overwrite")
  }else{
    #write temp
    write.csv(data, tempPath, row.names = FALSE, quote = TRUE)
    #write if not
    drop_upload(tempPath, path = dropsc, mode = "add")
  }
}


#save photo uploads w/ photoID
savePhoto <- function(photo){
  png("/Users/jmoxley/Downloads/here_lies_photo.png")
  fileName <- sprintf("here_lies_photo.png")
  file.copy(photo, "/Users/jmoxley/Downloads/here_lies_photo.png")
  dev.off()
}
#dropbox style
savePhoto2 <- function(photo, phid){
  fN <- paste(phid, tools::file_ext(photo$datapath), sep=".")
  print(fN)
  print(photo$name)
  
  #set pathways
  dropPath <- file.path(dropfin, fN)
  # tempPath <- file.path("/Users/jmoxley/Downloads", 
  #                       paste0(phid, "_", as.integer(Sys.time()), 
  #                              ".", tools::file_ext(photo$datapath)))
  tempPath <- file.path("/Users/jmoxley/Downloads", photo$name)
  print(dropPath)
  print(tempPath)
  print(photo)
  
  #prep photo
  #write data & upload
  cat("Copying file to:", tempPath ,"\n")
  file.copy(from = photo$datapath, to = tempPath)
  #file.copy(inFile$datapath, file.path("/Users/jmoxley/Downloads", inFile$name) )
  print(paste0("the local instance existence is ", file.exists(tempPath)))
  drop_upload(tempPath, dropPath, mode = "add")
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
#https://github.com/karthik/rdrop2#accessing-dropbox-on-shiny-and-remote-servers
#https://deanattali.com/blog/shiny-persistent-data-storage/